######Do not edit this section########
Param(
    $ServersToTest
)
######################################


##Test block##

Describe "One equals One"  {

	foreach ($server in $ServersToTest) {
		
		#Use context to log the target server name for each test in the output
		Context $server {
			It "Testing one equals one server $server" {

				1 | Should Be 1

			}
		}

	}
}



