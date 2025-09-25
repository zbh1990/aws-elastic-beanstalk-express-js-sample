pipeline {
    agent {
        docker {
            image 'node:16-bullseye'
            args '-u root:root'
        }
    }

    environment {
        APP_NAME = "app"
        DOCKER_REGISTRY = "docker.io/balalabalala" 
        DOCKER_IMAGE = "${DOCKER_REGISTRY}/${APP_NAME}:${env.BUILD_NUMBER}"
    }

    stages {

        stage('Install Java for Dependency Check') {
            steps {
                sh '''
                    apt-get update
                    apt-get install -y openjdk-17-jdk unzip curl
                    java -version
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
                sh 'npm install'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'npm test || true'
            }
        }

        stage('Security Scan - OWASP Dependency Check') {
            steps {
                sh '''
                    echo "Running OWASP Dependency-Check..."
                    mkdir -p dependency-check-report
                    curl -L -o dependency-check.zip https://github.com/jeremylong/DependencyCheck/releases/download/v9.2.0/dependency-check-9.2.0-release.zip
                    unzip -o dependency-check.zip -d /tmp/dependency-check
                    /tmp/dependency-check/dependency-check/bin/dependency-check.sh \
                        --project "NodeApp" \
                        --scan . \
                        --format ALL \
                        --out dependency-check-report

                    echo "Dependency-Check completed. Reports saved in dependency-check-report/"
                '''
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
            echo " Pipeline completed successfully"
        }
        failure {
            echo " Pipeline failed"
        }
    }
}

