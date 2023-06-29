
=begin
class version
  $currentversion =1107
  $newestversion=99999
  
  def getnewestversion
    begin
      url = "http://insurgence.cmdrd.com/version.txt"
      string=pbDownloadToString(url)
      $newestversion = string.to_i
    rescue
    end
  end
  
  def outdated
    getnewestversion
    if $newestversion > $currentversion
      return true
    else
      return false
    end
  end
end
=end