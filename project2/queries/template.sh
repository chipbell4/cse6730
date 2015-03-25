#!/bin/bash

#################################################
# Templates a file with a given properties file #
#################################################
template () {
  # $1 is the template file
  # $2 is the properties file  
  
  # first, we convert the properties into a list of SED replacements. This regex is awful, but essentially does this:
  # A line like name=chip becomes a sed command s/${name}/chip/g for replacing "variables" with a particular value
  touch sed_commands.txt
  cat $2 | sed -E 's/([a-zA-Z0-9]+)=([a-zA-Z0-9]+)/s\/\${\1}\/\2\/g/g' > sed_commands.txt

  # Now we run the sed file on our template file
  local template_results=`cat $1 | sed -f sed_commands.txt`

  # cleanup
  rm sed_commands.txt

  # now hand the result back to the caller
  echo $template_results
}
