// IDA Pro MCP - Jenkins Pipeline
// Builds and publishes the Python package to Artifactory

pipeline {
    agent {
        label 'python'
    }

    environment {
        // Artifactory configuration
        ARTIFACTORY_URL = credentials('artifactory-url')
        ARTIFACTORY_PYPI_REPO = 'pypi-local'
        ARTIFACTORY_CREDS = credentials('artifactory-credentials')
        
        // Package info
        PACKAGE_NAME = 'ida-pro-mcp'
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
        disableConcurrentBuilds()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    // Get version from pyproject.toml
                    env.PACKAGE_VERSION = sh(
                        script: "grep '^version = ' pyproject.toml | cut -d'\"' -f2",
                        returnStdout: true
                    ).trim()
                    
                    // Get Git commit SHA for build metadata
                    env.GIT_COMMIT_SHORT = sh(
                        script: 'git rev-parse --short HEAD',
                        returnStdout: true
                    ).trim()
                    
                    echo "Building ${PACKAGE_NAME} version ${PACKAGE_VERSION} (${GIT_COMMIT_SHORT})"
                }
            }
        }

        stage('Setup Python Environment') {
            steps {
                sh '''
                    python3 -m venv .venv
                    . .venv/bin/activate
                    pip install --upgrade pip
                    pip install build twine
                '''
            }
        }

        stage('Build Package') {
            steps {
                sh '''
                    . .venv/bin/activate
                    
                    # Clean previous builds
                    rm -rf dist/ build/ *.egg-info
                    
                    # Build the package (creates .whl and .tar.gz)
                    python -m build
                    
                    # List built artifacts
                    echo "Built packages:"
                    ls -la dist/
                '''
            }
        }

        stage('Validate Package') {
            steps {
                sh '''
                    . .venv/bin/activate
                    
                    # Check package with twine
                    twine check dist/*
                    
                    # Test install the package
                    pip install dist/*.whl
                    
                    # Verify it installed correctly
                    pip show ida-pro-mcp
                '''
            }
        }

        stage('Publish to Artifactory') {
            when {
                anyOf {
                    branch 'main'
                    buildingTag()
                }
            }
            steps {
                sh '''
                    . .venv/bin/activate
                    
                    # Configure pip to use Artifactory
                    twine upload \
                        --repository-url ${ARTIFACTORY_URL}/api/pypi/${ARTIFACTORY_PYPI_REPO} \
                        --username ${ARTIFACTORY_CREDS_USR} \
                        --password ${ARTIFACTORY_CREDS_PSW} \
                        dist/*
                    
                    echo "Published ${PACKAGE_NAME} ${PACKAGE_VERSION} to Artifactory"
                '''
            }
        }
    }

    post {
        success {
            echo "Build successful: ${PACKAGE_NAME} ${PACKAGE_VERSION}"
            archiveArtifacts artifacts: 'dist/*', fingerprint: true
        }
        failure {
            echo "Build failed"
        }
        always {
            cleanWs()
        }
    }
}
