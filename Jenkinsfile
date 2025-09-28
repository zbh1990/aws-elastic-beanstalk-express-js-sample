pipeline {
    agent {
        docker {
            image 'node:16-bullseye'
            args '-u root:root'
        }
    }

    environment {
        APP_NAME = "aws-app"
        DOCKER_REGISTRY = "docker.io/balalabalala"
        DOCKER_IMAGE = "${DOCKER_REGISTRY}/${APP_NAME}:${env.BUILD_NUMBER}"

          // docker:dind settings
        DOCKER_HOST = "tcp://docker:2376"
        DOCKER_CERT_PATH = "/certs/client"
        DOCKER_TLS_VERIFY = "
    }

    stages {

        stage('Install Docker CLI') {
            steps {
                sh '''
                    apt-get update
                    apt-get install -y docker.io
                    docker --version
                '''
            }
        }

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/zbh1990/aws-elastic-beanstalk-express-js-sample.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install --save'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'npm test'
            }
        }

        stage('Security Scan - Snyk') {
            steps {
                withCredentials([string(credentialsId: 'snyk-token', variable: 'SNYK_TOKEN')]) {
                    sh '''
                        echo "Running Snyk security scan..."
                        npm install -g snyk
                        snyk auth $SNYK_TOKEN
                        snyk test --severity-threshold=high
                    '''
                }
            }
        }


        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE} ."
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${DOCKER_IMAGE}
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully"
        }
        failure {
            echo "Pipeline failed"
        }
    }
}
