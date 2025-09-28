pipeline {
    agent any  

    environment {
        APP_NAME = "aws-app"
        DOCKER_REGISTRY = "docker.io/balalabalala"
        DOCKER_IMAGE = "${DOCKER_REGISTRY}/${APP_NAME}:${env.BUILD_NUMBER}"

          // docker:dind settings
        DOCKER_HOST = "tcp://docker:2376"
        DOCKER_CERT_PATH = "/certs/client"
        DOCKER_TLS_VERIFY = "1"
    }

    stages {

        stage('Bootstrap docker CLI on controller') {
            steps {
                sh '''
                set -e
                apt-get update
                apt-get install -y curl gnupg lsb-release || true
                curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - || true
                echo "deb [arch=amd64] https://www.download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list || true
                apt-get update || true
                apt-get install -y docker-ce-cli || apt-get install -y docker.io
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
            agent {
                docker {
                    image 'node:16-bullseye'
                    args '-u root:root'
                }
            }
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
                sh "DOCKER_HOST=$DOCKER_HOST docker build -t ${DOCKER_IMAGE} ."
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
