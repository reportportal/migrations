#!groovy

node {

    load "$JENKINS_HOME/jobvars.env"

        stage('Checkout') {
            checkout scm
            sh 'git checkout master'
            sh 'git pull'
        }

        stage('Build') {
            docker.withServer("$DOCKER_HOST") {
                        stage('Build Docker Image') {
                            sh 'docker-compose build migrations'
                        }

                        stage('Run Migrations') {
                            sh "docker-compose run --rm migrations up"
                        }
            }
        }
}