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
                sh "docker-compose -p reportportal -f $COMPOSE_FILE_RP run --rm migrations up"
            }
            stage('Push to ECR') {
                docker.withRegistry('34301710522.dkr.ecr.eu-central-1.amazonaws.com', 'ecr:eu-central-1:aws_credentials') {
                    docker.image('reportportal-dev/migrations').push('SNAPSHOT-${BUILD_NUMBER}')
                }
            }
        }
    }

}
