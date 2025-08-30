pipeline {
    agent any
    environment {
        DOCKER_REGISTRY = 'docker.io/vasanth1602'
        APP_NAME = 'blue-green-app'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }
    stages {
        stage('Build') {
            steps {
                dir('app') {
                    bat 'docker build -t %DOCKER_REGISTRY%/%APP_NAME%:%IMAGE_TAG% .'
                }
            }
        }
        stage('Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    bat 'echo %DOCKER_PASS% | docker login %DOCKER_REGISTRY% -u %DOCKER_USER% --password-stdin'
                    bat 'docker push %DOCKER_REGISTRY%/%APP_NAME%:%IMAGE_TAG%'
                }
            }
        }
        stage('Deploy') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'deploy-ssh', keyFileVariable: 'SSH_KEY')]) {
                    bat 'ssh -i %SSH_KEY% root@172.17.0.2 "bash /root/deploy/blue_green_deploy.sh %IMAGE_TAG%"'
                }
            }
        }
    }
}
