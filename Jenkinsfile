#!groovy

node {

    load "$JENKINS_HOME/jobvars.env"

    stage('Checkout') {
        checkout scm
    }


    stage('Build') {
        docker.withServer("$DOCKER_HOST") {
            stage('Build Docker Image') {
                sh 'docker build -t reportportal-dev/db-scripts -t $AWS_URI/db-scripts .'
            }
            stage('Run Migrations') {
                sh "docker-compose -p reportportal -f $COMPOSE_FILE_RP run --rm migrations up"
            }
            stage('Push to ECR') {
                sh 'docker tag reportportal-dev/db-scripts env.AWS_URI/db-scripts'
                def image = env.AWS_URI + '/db-scripts'
                def url = 'https://' + env.AWS_URI
                def credentials = 'ecr:' + env.AWS_REGION + ':aws_credentials'
                docker.withRegistry(url, credentials) {
                    docker.image(image).push('SNAPSHOT-${BUILD_NUMBER}')
                }
            }
        }
    }

}
