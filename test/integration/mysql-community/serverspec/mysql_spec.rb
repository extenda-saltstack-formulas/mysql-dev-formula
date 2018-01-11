require 'serverspec'

# Required by serverspec
set :backend, :exec

describe command("java -version") do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should match /java version \"1.7.0_79\"/ }
end

describe command("echo $JAVA_HOME") do
  its(:stdout) { should match /\/opt\/jdk1.7.0_79/ }  
end
