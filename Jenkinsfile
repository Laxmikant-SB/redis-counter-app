pipeline {
    agent any

    environment {
        APP_NAME = 'redis-counter-app'
        DOCKER_IMAGE = "laxmikant07/${APP_NAME}"
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Checking out code...'
                checkout scm
            }
        }

        stage('Test') {
            steps {
                echo 'Running tests...'
                sh 'python3 test_app.py'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh "docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} ."
                sh "docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest"
                echo "Built image: ${DOCKER_IMAGE}:${BUILD_NUMBER}"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo 'Pushing to Docker Hub...'
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh "docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}"
                    sh "docker push ${DOCKER_IMAGE}:latest"
                }
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying application...'
                sh """
                    docker stop ${APP_NAME} || true
                    docker rm ${APP_NAME} || true
                    docker run -d \\
                        --name ${APP_NAME} \\
                        --restart unless-stopped \\
                        ${DOCKER_IMAGE}:${BUILD_NUMBER}
                    echo 'Deployment complete!'
                """
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline succeeded! App deployed.'
        }
        failure {
            echo '❌ Pipeline failed! Check the logs.'
        }
        always {
            echo "Build #${BUILD_NUMBER} finished."
        }
    }
}
