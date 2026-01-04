pipeline {
    agent any

    environment {
        // Docker registry configuration - customize for your environment
        DOCKER_REGISTRY = 'your-registry.example.com'
        IMAGE_NAME = 'ida-pro-mcp'
        
        // Use git commit SHA for unique tagging
        GIT_COMMIT_SHORT = "${GIT_COMMIT.take(7)}"
        IMAGE_TAG = "${GIT_COMMIT_SHORT}"
        
        // Docker credentials ID configured in Jenkins
        DOCKER_CREDENTIALS_ID = 'docker-registry-credentials'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}")
                }
            }
        }

        stage('Tag Latest') {
            steps {
                script {
                    sh "docker tag ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest"
                }
            }
        }

        stage('Push to Registry') {
            steps {
                script {
                    docker.withRegistry("https://${DOCKER_REGISTRY}", DOCKER_CREDENTIALS_ID) {
                        docker.image("${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}").push()
                        docker.image("${DOCKER_REGISTRY}/${IMAGE_NAME}:latest").push()
                    }
                }
            }
        }
    }

    post {
        always {
            // Clean up local Docker images
            sh "docker rmi ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} || true"
            sh "docker rmi ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest || true"
        }
        success {
            echo "Successfully built and pushed ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
        }
        failure {
            echo "Build or push failed"
        }
    }
}
