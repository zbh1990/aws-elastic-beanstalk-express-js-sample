pipeline {
    agent {
        docker {
            image 'node:16-bullseye'
            args '-u root:root -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    environment {
        APP_NAME = "app"
        DOCKER_REGISTRY = "docker.io/你的DockerHub用户名"
        DOCKER_IMAGE = "${DOCKER_REGISTRY}/${APP_NAME}:${env.BUILD_NUMBER}"
    }

    stages {

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

        stage('Security Scan - OWASP Dependency Check') {
            steps {
                sh '''
                    echo "Running Dependency-Check via Docker..."
                    docker run --rm \
                        -v $(pwd):/src \
                        -v $(pwd)/dependency-check-report:/report \
                        owasp/dependency-check:9.2.0 \
                        --scan /src \
                        --format ALL \
                        --out /report \
                        --failOnCVSS 7
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
            echo "Pipeline completed successfully"
        }
        failure {
            echo "Pipeline failed"
        }
    }
}
