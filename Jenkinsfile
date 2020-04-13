#!groovy

node {

    load "$JENKINS_HOME/jobvars.env"

    stage('Checkout') {
        checkout scm
    }


    stage('Build') {
        docker.withServer("$DOCKER_HOST") {
            stage('Build Docker Image') {
                sh 'docker build -t reportportal-dev/migrations -t $AWS_URI/db-scripts .'
            }
            stage('Run Migrations') {
                sh "docker-compose -p reportportal -f $COMPOSE_FILE_RP run --rm migrations up"
            }
            stage('Push to ECR') {
                docker.withRegistry('https://$AWS_URI', 'ecr:$AWS_REGION:aws_credentials') {
                    docker.image('$AWS_URI/db-scripts').push('SNAPSHOT-184')
                }
            }
        }
    }

}
