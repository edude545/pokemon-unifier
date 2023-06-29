#Reworked Masuda method by Deukhoofd
#This system checks the country code from the registry and returns the continent this is on
 
def getCountryCode
    # This function returns the country the user currently is in by country code (similar to telephone country codes)
    # for more info about country codes: https://en.wikipedia.org/wiki/List_of_country_calling_codes
    # And: http://www.robvanderwoude.com/icountry.php
    # This checks if is running on windows. Is this needed with Wine/does Wine have a registry value for country code?
    if RUBY_PLATFORM.downcase =~ /win32/
        #check registry for country code
        ret=MiniRegistry.get(MiniRegistry::HKEY_CURRENT_USER,
            "Control Panel\\International", "iCountry","0").to_s
  end
end
 
def getRegion
    # this function returns the continent based on the country code
    z = getCountryCode.to_i
      # Canada has country code 2 in windows registry, so need to set it to North America region
      z=1 if (z==2)
    x = z.to_s.split('').map
      y = x[0]
      m = y.to_i
      # Europe has both continent codes 3 and 4, so need to merge those and properly handle everything above
      if m > 4
        m=(m-1)
        return m
      else
        return m
      end
    end
   
def getRegionstring
  # For if you ever need to have it as a string for some obscure reason
  getRegion.to_s
end
 
# Simple testing responses
#Kernel.pbMessage(_INTL(getCountryCode))
 
#Kernel.pbMessage(_INTL(getRegionstring))