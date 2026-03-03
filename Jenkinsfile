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
                  sh "mvn clean verify org.sonarsource.scanner.maven:sonar-maven-plugin:sonar -Dsonar.projectKey=numeric-application -Dsonar.projectName='numeric-application'"
              }
              timeout(time: 1, unit: 'HOURS'){
                script {
                    waitForQualityGate abortPipeline: true
                }
              }
    }
  }
        //stage('PIT mutation testing'){
           // steps {
               // sh "mvn org.pitest:pitest-maven-plugin:mutationCoverage -U"
            //}
        //}
        stage('OWASP dependency check'){
            steps {
                withCredentials([string(credentialsId: 'nvd-api-key', variable: 'NVD_API_KEY')]) {
                sh "mvn dependency-check:check -DnvdApiKey=$NVD_API_KEY, -DnvdApiDelay=6000"
            }
        }     
            post {
                always {
                    dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
                }
            }
        }
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
