#!groovy

node {

    load "$JENKINS_HOME/jobvars.env"

    stage('Checkout') {
        checkout scm
    }

    stage('Build') {
        docker.withServer("$DOCKER_HOST") {
            stage('Build Docker Image') {
                sh 'docker-compose -p reportportal build migrations'
            }

            stage('Run Migrations') {
                sh "docker-compose -p reportportal run --rm migrations up"
            }
        }
    }
}
