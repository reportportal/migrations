#!groovy

node {

    load "$JENKINS_HOME/jobvars.env"

    stage('Checkout') {
        checkout scm
    }

    stage('Build') {
        docker.withServer("$DOCKER_HOST") {
            stage('Build Docker Image') {
                sh 'docker build -t reportportal-dev/migrations .'
            }

            stage('Run Migrations') {
                docker.withServer("$DOCKER_HOST") {
                    sh "docker-compose -p reportportal -f $COMPOSE_FILE_RP run --rm migrations up"
                }
            }
        }
    }
}
