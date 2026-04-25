pipeline {
    agent any

    environment {
        IMAGE_NAME = "madhusudhanap05/github-profile-summarizer"
        IMAGE_TAG = "v${env.BUILD_NUMBER}"
        MAX_REPOS = "50"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Docker Build') {
            steps {
                withCredentials([string(credentialsId: 'github-token-secret', variable: 'GITHUB_TOKEN_VALUE')]) {
                    sh """
                        docker build \
                        --build-arg VITE_GITHUB_TOKEN=${GITHUB_TOKEN_VALUE} \
                        --build-arg VITE_MAX_REPOS=${MAX_REPOS} \
                        -t ${IMAGE_NAME}:${IMAGE_TAG} .
                    """
                }
            }
        }

        stage('Docker Login & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'DockerHub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                }
                sh """
                    docker push ${IMAGE_NAME}:${IMAGE_TAG}
                    docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
                    docker push ${IMAGE_NAME}:latest
                """
            }
        }

        stage('Deploy Image') {
            steps {
                sh """
                    docker rm -f github-profile-summarizer || true
                    docker run -d --name github-profile-summarizer -p 8081:80 ${IMAGE_NAME}:${IMAGE_TAG}
                """
            }
        }
    }

    post {
        always {
            echo "✅ Docker image pushed and deployed: ${IMAGE_NAME}:${IMAGE_TAG}"
        }
    }
}
