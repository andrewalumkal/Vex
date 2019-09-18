######Do not edit this section########
Param(
    $ServersToTest
)
######################################


##Test block##

Describe "Two equals Two"  {

	foreach ($server in $ServersToTest) {
		
		#Use context to log the target server name for each test in the output
		Context $server {
			It "Testing two equals two server $server" {

				2 | Should Be 2

			}
		}

	}
}



