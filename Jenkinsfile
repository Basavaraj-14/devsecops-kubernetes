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
                docker build -t devsecops:$GIT_COMMIT .
                docker tag devsecops:$GIT_COMMIT 187868012081.dkr.ecr.ap-south-1.amazonaws.com/devsecops:$GIT_COMMIT
                docker push 187868012081.dkr.ecr.ap-south-1.amazonaws.com/devsecops:$GIT_COMMIT '''
            }
          }
        }
        stage('kubernets deployment'){
          steps {
            withKubeConfig([credentialsId: 'kubeconfig']) {
            sh ''' sed -i 's#replace#187868012081.dkr.ecr.ap-south-1.amazonaws.com/devsecops:${GIT_COMMIT}#g' k8s_deployment_service.yaml
                  kubectl apply -f k8s_deployment_service.yaml '''
            }
          }
        }
    }
}
