#!groovy

node {

    load "$JENKINS_HOME/jobvars.env"

    stage('Checkout') {
        checkout scm
    }


    stage('Build') {
        docker.withServer("$DOCKER_HOST") {
            stage('Build Docker Image') {
                sh 'docker build -t $AWS_URI/db-scripts .'
            }
            stage('Run Migrations') {
                sh "docker-compose -p reportportal -f $COMPOSE_FILE_RP run --rm migrations up"
            }
            stage('Push to ECR') {
                def uri = 'https://' + $AWS_URI;
                def credentials = 'ecr:' + $AWS_REGION + ':aws_credentials';
                docker.withRegistry(uri, credentials) {
                    docker.image('$AWS_URI/db-scripts').push('SNAPSHOT-184')
                }
            }
        }
    }

}
