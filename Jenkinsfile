pipeline {
    agent any
    tools {
        maven 'Maven-3.9'
    }

    stages {

        stage('Build Artifact') {
            steps {
                sh 'mvn clean package -DskipTests=true'
                archiveArtifacts artifacts: 'target/*.jar'
            }
        }

        stage('Unit Testing') {
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
        stage('sonarQube SAST'){
          steps {
              withSonarQubeEnv('SonarQube-Sanner') {
                  sh "mvn clean verify org.sonarsource.scanner.maven:sonar-maven-plugin:sonar -Dsonar.projectKey=devsecops-numeric-application -Dsonar.projectName='devsecops-numeric-application'"
              }
    }
  }
        //stage('PIT mutation testing'){
           // steps {
               // sh "mvn org.pitest:pitest-maven-plugin:mutationCoverage -U"
            //}
        //}

        stage('Build and Push Docker Image') {
            steps {
                withAWS(credentials: 'jenkinscreds', region: 'ap-south-1') {
                    sh '''
                        aws ecr get-login-password --region ap-south-1 | \
                        docker login --username AWS --password-stdin 187868012081.dkr.ecr.ap-south-1.amazonaws.com

                        docker build -t devsecops:${GIT_COMMIT} .
                        docker tag devsecops:${GIT_COMMIT} 187868012081.dkr.ecr.ap-south-1.amazonaws.com/devsecops:${GIT_COMMIT}
                        docker push 187868012081.dkr.ecr.ap-south-1.amazonaws.com/devsecops:${GIT_COMMIT}
                    '''
                }
            }
        }

        stage('Kubernetes Deployment') {
            steps {
                    sh '''
                        sed -i "s#replace#187868012081.dkr.ecr.ap-south-1.amazonaws.com/devsecops:${GIT_COMMIT}#g" k8s_deployment_service.yaml
                        kubectl apply -f k8s_deployment_service.yaml
                    '''
            }
        }
    }
}
