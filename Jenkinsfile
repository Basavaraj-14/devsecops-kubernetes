pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //so that they can be downloaded later
            }
        }
        stage('unit testing'){
          steps {
            sh 'mvn test'
          }
          post {
            always {
              junit 'target/surefire-reports/*.xml'
              jacoco execPattern: 'target/jacoco.exec'
            }
          }
        }
        stage('build and push docker image'){
          steps {
            withAWS(credentials: 'jenkinscreds', region: 'ap-south-1'){
              sh '''
                aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 187868012081.dkr.ecr.ap-south-1.amazonaws.com
                docker build -t devsecops:latest .
                docker tag devsecops:latest 187868012081.dkr.ecr.ap-south-1.amazonaws.com/devsecops:latest
                docker push 187868012081.dkr.ecr.ap-south-1.amazonaws.com/devsecops:latest '''
            }
          }
        }
    }
}
