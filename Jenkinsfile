#!groovy

node {

    load "$JENKINS_HOME/jobvars.env"

    stage('Checkout') {
        checkout scm
    }


    stage('Build') {
        withEnv(["AWS_URI=${AWS_URI}", "AWS_REGION=${AWS_REGION}"]) {

            stage('Build Docker Image') {
                sh 'docker build -t ${AWS_URI}/migrations:SNAPSHOT-${BUILD_NUMBER} .'
            }

            stage('Push to ECR') {
                def image = env.AWS_URI + '/migrations' + ':SNAPSHOT-' + env.BUILD_NUMBER
                def url = 'https://' + env.AWS_URI
                def credentials = 'ecr:' + env.AWS_REGION + ':aws_credentials'
                docker.withRegistry(url, credentials) {
                    docker.image(image).push()
                }
            }

            stage('Cleanup') {
                docker.withServer("$DOCKER_HOST") {
                    withEnv(["AWS_URI=${AWS_URI}"]) {
                        sh 'docker rmi ${AWS_URI}/migrations:SNAPSHOT-${BUILD_NUMBER}'
                    }
                }
            }
        }
    }

}
