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
            agent any
            steps {
                sh '''
                set -eux
                apt-get update
                apt-get install -y docker.io
                docker --version
                '''
            }
            }
                
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/zbh1990/aws-elastic-beanstalk-express-js-sample.git'
                sh 'mkdir -p logs'
            }
        }

         stage('Install Dependencies') {
            agent {
                docker {
                    image 'node:16'
                    args '-u root:root'
                }
            }
            steps {
                sh '''
                    set -euo pipefail
                    mkdir -p logs
                    npm install --save 2>&1 | tee logs/install.log
                '''
            }
        }

        stage('Run Tests') {
            steps {
                 sh '''
                    set -euo pipefail
                    mkdir -p logs
                    npm test 2>&1 | tee logs/test.log
                    '''
            }
        }

        stage('Security Scan - Snyk') {
            steps {
                withCredentials([string(credentialsId: 'snyk-token', variable: 'SNYK_TOKEN')]) {
                    sh '''
                        echo "Running Snyk security scan..."
                        npm install -g snyk
                        snyk auth $SNYK_TOKEN
                        snyk test --severity-threshold=high 2>&1 | tee logs/scan.log
                    '''
                }
            }
        }


        stage('Build Docker Image') {
            steps {
                sh "DOCKER_HOST=$DOCKER_HOST docker build -t ${DOCKER_IMAGE} . 2>&1 | tee logs/build.log"
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${DOCKER_IMAGE} 2>&1 | tee logs/push.log
                    '''
                }
            }
        }
    }

    post {
        always {
            // 只归档你要的 5 个日志
            archiveArtifacts artifacts: 'logs/install.log,logs/test.log,logs/scan.log,logs/build.log,logs/push.log',
                                allowEmptyArchive: true, fingerprint: true
        }   
        success {
            echo "Pipeline completed successfully"
        }
        failure {
            echo "Pipeline failed"
        }
    }
}
