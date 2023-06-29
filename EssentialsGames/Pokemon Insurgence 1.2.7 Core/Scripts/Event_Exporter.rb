def Kernel.ExportEvents
    File.open("Event_Output4", 'w') do |f2|

  for i in 1..801
    next if !pbRxdataExists?(sprintf("Data/Map%03d",i))
    map=Game_Map.new
    map.setup(i)
    next if !map.events || !map.events.values
    for ev in map.events.values
      next if !ev || !ev.event.pages
       for page in ev.event.pages
       for inst in page.list
         next if !inst
         code = inst.code
         code = code.to_s if !code.is_a?(String)
        # Kernel.pbMessage(code+" "+par)
        
        
        
                  tstring =""
                  tstring += (map.name + " (ID:"+map.map_id.to_s+")")
                  tstring += ","
                  tstring += ("X:"+ev.x.to_s)
                  tstring += ","
                  tstring += ("Y:"+ev.y.to_s)
                  tstring += ","
                  tstring += code
                  tstring += ","
                  for par in inst.parameters
                             par = par.to_s if !par.is_a?(String) 
                  tstring += par
                                    tstring += ","

                  end
                  tstring += "|||"

                  f2.puts(tstring)
                end

       end;end
     end
  end
                  Kernel.pbMessage("Exported Data.")

end

