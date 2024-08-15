# Sonoff NSPanel Tasmota Lovelace UI Berry Driver (Extended Flashing to faster speeds; improved Error Handling)| code by joBr99
# based on;
# Sonoff NSPanel Tasmota (Nextion with Flashing) driver | code by peepshow-21
# based on;
# Sonoff NSPanel Tasmota driver v0.47 | code by blakadder and s-hadinger

# Example Flash
# FlashNextion http://ip-address-of-your-homeassistant:8123/local/nspanel.tft
# FlashNextion http://nspanel.pky.eu/lui.tft

# command format: entityUpd,heading,navigation,[,type,internalName,iconId,displayName,optionalValue]x4
import string
import persist
import json

var mqtttopic         = "tele/nspanel_0627"
var mqtttopiccmnd     = "cmnd/nspanel_0627"
var addr_get_location = "https://ipapi.co/json" 
var loc               = "~prague"

var widget = {
    "0": [ "screensaver", "weatherUpdate~",[
            [],
            [],
            [
                ["","","","21557","","","°C"],
                ["","","","21557","","",""],
                ["","","","21557","","",""],
                ["","","","21557","","",""],
                ["","","","","","",""],
                ["","","","21557","","",""]
            ]
        ]],
    "1": [ "cardEntities", "entityUpd~",[
            [
                "SolarEco Regulator"
            ],
            [
                ["button", "navigate.prev", "", "65535"], 
                ["button", "navigate.next", "", "65535"]
            ],
            [
                ["text", "sensor.regulator_voltage", "V", "17299", "Voltage", "", ""],
                ["text", "sensor.regulator_current", "I", "17299", "Current", "", ""],
                ["text", "sensor.regulator_power", "W", "17299", "Power", "", ""],
                ["text", "sensor.regulator_tempCooler", "C", "17299", "Cooler Temp", "", ""]
            ]
        ]],
    "2": [ "cardEntities", "entityUpd~",[
            [
                "SolarEco Regulator"
            ],
            [
                ["button", "navigate.prev", "", "65535"],
                ["button", "navigate.next", "", "65535"]
            ],
            [
                ["text", "sensor.regulator_dayEnergy", "W", "17299", "Day Energy", "", ""],
                ["text", "sensor.regulator_totalEnergy", "W", "17299", "Total Energy", "", ""],
                ["text", "sensor.regulator_tempBoiler", "C", "17299", "Boiler Temp", "", ""]
            ]
        ]],
    "3": [ "cardEntities", "entityUpd~",[
            [
                "SolarEco Regulator"
            ],
            [
                ["button", "navigate.prev", "", "65535"],
                ["button", "navigate.next", "", "65535"]
            ],
            [
                ["switch", "switch.regulator_onoff", "", "17299", "Turn Off", "0", ""],
                ["switch", "switch.regulator_relay", "", "17299", "Relay on", "0", ""],
                ["switch", "switch.nspanel_relay1", "", "17299", "LOut-1", "0", ""],
                ["switch", "switch.nspanel_relay2", "", "17299", "LOut-2", "0", ""]
            ]
        ]],
    "4": [ "cardEntities", "entityUpd~",[
            [
                "SolarEco Regulator"
            ],
            [
                ["button", "navigate.prev", "", "65535"],
                ["button", "navigate.next", "", "65535"]
            ],
            [
                ["text", "text.ip_nspanel", "", "17299", "Display", "", ""],
                ["text", "text.ip_regulator", "", "17299", "Regulator", "", ""],
                ["text", "text.versionHW", "", "17299", "Hardware", "", ""],
                ["text", "text.versionSW", "", "17299", "Software", "", ""]
            ]
        ]],
    "5": [ "cardThermo", "entityUpd~",[
            [
                "Heater control"
            ],
            [
                ["button", "navigate.prev", "", "65535"],
                ["button", "navigate.next", "", "65535"]
            ],
            [
                ["heater", "", "", "", "", "", ""],
                ["","","","","","",""],
                ["","","","","","",""],
                ["","","","","","",""],
                ["","","","","","",""],
                ["","","","","","",""],
                ["","","","","","",""],
                ["","","","","","",""],
                ["","","","","","",""],
                ["Currently","Status","","","","1",""]
            ]
        ]],
    "6": [ "cardEntities", "entityUpd~",[
            [
                "Settings"
            ],
            [
                ["button", "navigate.prev", "", "65535"],
                ["button", "navigate.next", "", "65535"]
            ],
            [
                ["button", "button.language", "", "17299", "Language", "English", ""],
                ["button", "button.restart", "", "17299", "Restart", "Restart", ""],
                ["number", "input_number.sleep", "", "17299", "Sleep (s)", "10|0|60", ""]
            ]
        ]]
}

var weather_icon = {
    "": "",      # Unknown             
    "113": "",    # Sunny      
    "116": "",    # PartlyCloudy   
    "119": "",    # Cloudy             
    "122": "",    # VeryCloudy           
    "143": "",   # Fog                 
    "176": "",   # LightShowers     
    "179": "",   # LightSleetShowers 
    "182": "",   # LightSleet        
    "185": "",   # LightSleet        
    "200": "",   # ThunderyShowers  
    "227": "",   # LightSnow  
    "230": "",   # HeavySnow        
    "248": "",   # Fog                 
    "260": "",   # Fog                 
    "263": "",   # LightShowers     
    "266": "",   # LightRain      
    "281": "",   # LightSleet        
    "284": "",   # LightSleet        
    "293": "",   # LightRain      
    "296": "",   # LightRain      
    "299": "",   # HeavyShowers      
    "302": "",   # HeavyRain        
    "305": "",   # HeavyShowers      
    "308": "",   # HeavyRain        
    "311": "",   # LightSleet        
    "314": "",   # LightSleet        
    "317": "",   # LightSleet        
    "320": "",   # LightSnow  
    "323": "",   # LightSnowShowers 
    "326": "",   # LightSnowShowers 
    "329": "",   # HeavySnow        
    "332": "",   # HeavySnow        
    "335": "",   # HeavySnowShowers   
    "338": "",   # HeavySnow        
    "350": "",   # LightSleet        
    "353": "",   # LightSleet        
    "356": "",   # HeavyShowers      
    "359": "",   # HeavyRain        
    "362": "",   # LightSleetShowers 
    "365": "",   # LightSleetShowers 
    "368": "",   # LightSnowShowers 
    "371": "",   # HeavySnowShowers   
    "374": "",   # LightSleetShowers 
    "377": "",   # LightSleet        
    "386": "",   # ThunderyShowers  
    "389": "",   # ThunderyHeavyRain  
    "392": "",   # ThunderySnowShowers
    "395": ""   # HeavySnowShowers   
}

var iconAll = {
    "fire":  "",
    "power": "",
    "en": "",
    "cs": ""
}
var wifiIcon = {
    "0": "",  
    "1": "",
    "2": "",
    "3": "",
    "4": "",
    "5": ""
}
var targetTemp          = persist.has("targetTemp")         ? persist.targetTemp        : "0"
var minTemp             = persist.has("minTemp")            ? persist.minTemp           : "0"
var maxTemp             = persist.has("maxTemp")            ? persist.maxTemp           : "1000"
var tempStep            = persist.has("tempStep")           ? persist.tempStep          : "5"
var hysteresis          = persist.has("hysteresis")         ? persist.hysterisis        : "0.5"
var hvac_mode           = persist.has("hvac_mode")          ? persist.hvac_mode         : "off"
var doubleTapToUnlock   = false
var select_language     = persist.has("select_language")    ? persist.select_language   : "cs" 
var _sleepTimeout       = persist.has("_sleepTimeout")      ? int(persist._sleepTimeout): 20
var sleepMaxMin         = "|0|60" 

var hvac_modes = ["off", "heat", "cool", "heat_cool", "auto", "dry", "fan_only"] 

var weekdays            = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
var nickname_weekdays   = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]  
var months              = ["December", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November"]
var temperatureInternal = 0
var _currentPageId      = 0
var _pageSize           = size(widget)-1
var _sleepBrightness    = 20
var _screenBrightness   = 100
var _parseCommands 
var _requestedPageId    = 0
var latitude
var longitude
var m100Sec=0
var startup             = false
var wifiConnected       = false
var prev_wifiConnected  = true

var voltage = 0, current = 0, power = 0, tempCooler = 0, dayEnergy = 0, tempBoiler = 0, totalEnergy = 0, regulatorIP, mode, relayAC, versionHW, versionSW    
var refresh_enable = 1, solo_operate_nspanel_relay1
var tempVal = 10, tempSec = 30 
class Nextion : Driver
    static header = bytes('55BB')
    
    static flash_block_size = 4096
    
    var flash_mode
    var flash_start_millis
    var flash_size
    var flash_written
    var flash_buff
    var flash_offset
    var flash_proto_version
    var flash_proto_baud
    var awaiting_offset
    var tcp
    var ser
    var last_per
    var url
    var ts, tcp_client, tcp_send, connection
    var inParameter, statusRegulator, setStatusButton 
    var wait_refresh, relayStatusButton, statusRelay
    var ip_own
    var strings_translate
    
    def split_55(b)
      var ret = []
      var s = size(b)   
      var i = s-2   # start from last-1
      while i > 0
        if b[i] == 0x55 && b[i+1] == 0xBB           
          ret.push(b[i..s-1]) # push last msg to list
          b = b[(0..i-1)]   # write the rest back to b
        end
        i -= 1
      end
      ret.push(b)
      return ret
    end

    def crc16(data, poly)
      if !poly  poly = 0xA001 end
      # CRC-16 MODBUS HASHING ALGORITHM
      var crc = 0xFFFF
      for i:0..size(data)-1
        crc = crc ^ data[i]
        for j:0..7
          if crc & 1
            crc = (crc >> 1) ^ poly
          else
            crc = crc >> 1
          end
        end
      end
      return crc
    end

    # encode using custom protocol 55 BB [payload length] [payload length] [payload] [crc] [crc]
    def encode(payload)
      var b = bytes()
      b += self.header
      b.add(size(payload), 2)   # add size as 2 bytes, little endian
      b += bytes().fromstring(payload)
      var msg_crc = self.crc16(b)
      b.add(msg_crc, 2)       # crc 2 bytes, little endian
      return b
    end

    def encodenx(payload)
        var b = bytes().fromstring(payload)
        b += bytes('FFFFFF')
        return b
    end

    def sendnx(payload)
        var payload_bin = self.encodenx(payload)
        self.ser.write(payload_bin)
        log(string.format("NXP: Nextion command sent = %s",str(payload_bin)), 3)       
    end

    def send(payload)
        var payload_bin = self.encode(payload)
        if self.flash_mode==1
            log("NXP: skipped command becuase still flashing", 3)
        else 
            self.ser.write(payload_bin)
            log("NXP: payload sent = " + str(payload_bin), 3)
        end
    end

    def write_to_nextion(b)
        self.ser.write(b)
    end

    def screeninit()
        log("NXP: Screen Initialized")
        self.sendnx("recmod=1")        
    end

    def init_page(pageId)
        var pageIdTxt = str(pageId)
        if (!(widget.contains(pageIdTxt)))
            return
        end
        self.send("pageType~"+widget[pageIdTxt][0])
        _requestedPageId = pageId
    end
    
    def init_component(pageId)
        var pageIdTxt  = str(pageId)
        var components
        try components = widget[pageIdTxt][2] 
        except 'key_error'
            print("key_error in init_component()")
            return
        end
        var buf        = ""
        if components[0] != []         
            buf += components[0][0] + "~"
        end
        if components[1] != []
            for entity:components[1]
                for param:entity
                  buf += param + "~"
                end 
               buf += "~~" 
            end
        end
        if components[2] != []
            for entity:components[2]                     
                for i:0..4
                    buf += entity[i]
                    buf += "~"
                end
                if widget[pageIdTxt][0] != "cardThermo"
                    buf += entity[5] + " " + entity[6]
                elif widget[pageIdTxt][0] == "cardThermo"
                    if components[2][0] == entity || components[2][9] == entity
                        buf += entity[5] + "~" + entity[6]                  
                    else
                        buf = string.split(buf, -2)[0]      # Why -2 instead of -1!!!!
                    end
                end                
                buf += "~"
            end 
        end
        self.send(widget[pageIdTxt][1]+buf)
    end

    def get_page_id(pageName)
        var i = 0
        var iTxt = "0"
        for j:widget
            if widget[iTxt][0] == pageName
                break
            end
            i += 1
            iTxt = str(i)
        end
        return iTxt
    end

    # def boot_init()
        
    # end

    def parse_from_nextion(msg)
        _parseCommands = string.split(msg,",")
        if _parseCommands[1] == "startup"
            print("Startup")
            self.send("timeout~"+str(_sleepTimeout))
            self.send("dimmode~100~100~6371")
            self.wifi_check()
            self.set_ip()
            self.get_location()
            self.set_forecast()
            self.set_date()
            self.set_clock()
            self.set_language(select_language)
            self.translate_static_strings()
            self.init_page(0)
            self.create_server()
            self.init_mdns()
            tasmota.cmd("Status 10") 
            startup = true
        elif _parseCommands[1] == "renderCurrentPage"
            _currentPageId = _requestedPageId
            var pageIdTxt  = str(_currentPageId)
            if widget[pageIdTxt][0] == "cardThermo" #_currentPageId == 3
                self.run_hysteresis()
            end
            # if widget[pageIdTxt][0] == "screenSaver"
            #     self.set_statusIcons()
            # end
            self.init_component(_currentPageId)
        #    tasmota.publish(mqtttopic + "/PAGEEVENT",string.format("{\"pageId\":\"%s\"}",_currentPageId)) 
        elif _parseCommands[1] == "sleepReached"
            self.set_clock()
            self.init_page(self.get_page_id("screensaver"))
            self.set_statusIcons()
        elif _parseCommands[1] == "buttonPress2"
            if _parseCommands[2] == "navigate.prev" #widget[str(_currentPageId)][2][1][0][1]
                _currentPageId -= 1
                if(_currentPageId == 0)
                    _currentPageId = _pageSize
                end
                self.init_page(_currentPageId)
            elif _parseCommands[2] == "navigate.next" #widget[str(_currentPageId)][2][1][1][1]
                _currentPageId += 1
                if(_currentPageId > _pageSize)
                    _currentPageId = 1
                end
                self.init_page(_currentPageId)
            elif _parseCommands[2] == "screensaver"
                if _parseCommands[3] == "bExit"
                    if(doubleTapToUnlock == true)
                        if int(_parseCommands[4]) > 1
                            self.init_page(1)
                        end
                    else 
                        self.init_page(1)
                    end
                    if startup == true
                        startup = false
                        doubleTapToUnlock = true
                        self.send("dimmode~10~100~6371")
                    end
                end
            elif _parseCommands[2] == "heater"
                if _parseCommands[3] == "tempUpd"
                    targetTemp = _parseCommands[4]
                    widget[self.get_page_id("cardThermo")][2][2][0].setitem(2,targetTemp)
                    persist.targetTemp = targetTemp
                elif _parseCommands[3] == "hvac_action" && _parseCommands[4] == "heater1"
                    if hvac_mode == "heat" 
                        hvac_mode = "off"
                    elif hvac_mode == "off" 
                        hvac_mode = "heat"
                        solo_operate_nspanel_relay1 = false
                    end
                   persist.hvac_mode = hvac_mode
                end
                persist.save()
                self.run_hysteresis()
            elif _parseCommands[2] == "switch.regulator_onoff"
                if _parseCommands[3] == "OnOff"
                    if self.connection == true
                        self.setStatusButton = int(_parseCommands[4])
                        self.wait_refresh = true
                        self.nssend("\r\n&\r\n")
                    end
                end
            elif _parseCommands[2] == "switch.regulator_relay"
                if _parseCommands[3] == "OnOff"
                    if self.connection == true
                        self.relayStatusButton = int(_parseCommands[4])
                        self.wait_refresh = true
                        self.nssend("\r\n%\r\n")
                    end
                end
            elif _parseCommands[2] == "button.language"
                if select_language == "en"
                    self.set_language("cs")
                elif select_language == "cs"
                    self.set_language("en")
                end
                self.translate_static_strings()
                self.set_date()
            elif _parseCommands[2] == "button.restart"
                tasmota.cmd("Restart 1")
            elif _parseCommands[2] == "switch.nspanel_relay1"
                if _parseCommands[3] == "OnOff"            
                    if _parseCommands[4] == "1"                       
                        tasmota.set_power(0, true)
                        self.set_nspanel_relay1("1")
                    elif _parseCommands[4] == "0"                        
                        tasmota.set_power(0, false)
                        self.set_nspanel_relay1("0")
                    end
                end
            elif _parseCommands[2] == "switch.nspanel_relay2"
                if _parseCommands[3] == "OnOff"            
                    if _parseCommands[4] == "1"                       
                        tasmota.set_power(1, true)
                        self.set_nspanel_relay2("1")
                    elif _parseCommands[4] == "0"                        
                        tasmota.set_power(1, false)
                        self.set_nspanel_relay2("0")
                    end
                end
            elif _parseCommands[2] == "input_number.sleep"
                if _parseCommands[3] == "number-set"
                    self.set_sleepTime(int(_parseCommands[4]))
                end
            end
        end
    end

    def set_clock()
        var now = tasmota.rtc()
        var time_raw = now['local']
        var nsp_time = tasmota.time_dump(time_raw)
        var time_payload = string.format("%02d:%02d",nsp_time['hour'],nsp_time['min'])
        self.send("time~" + time_payload)
        return nsp_time
    end

    def set_date()
        var now = tasmota.rtc()
        var time_raw = now['local']
        var nsp_time = tasmota.time_dump(time_raw)
        var date_payload = string.format("%s, %02d. %s %04d ", self.obtain_string(weekdays[nsp_time['weekday']]), nsp_time['day'], self.obtain_string(months[nsp_time['month']]), nsp_time['year'])
        self.send("date~" + date_payload)
        return nsp_time
    end

    def every_50ms()
        if self.connection == true
            self.nsloop()
        elif self.ts != nil
            if self.ts.hasclient()
                self.tcp_client = self.ts.accept()
                if self.tcp_client != nil
                    self.tcp_send = "\nConnected nspanel server\n"
                    self.nsloop()
                    self.connection = true
                end
            end
        else 
            self.connection = false
        end
        self.inParameter += 1 
        if self.inParameter >= 100
            self.inParameter = 20
            self.dzd_regulator_page_null()
            if self.connection == true
                self.tcp_client.close()
            end
            self.connection = false
        end
        self.wifi_check()
        self.set_statusIcons()
    end

    def wifi_check()
        wifiConnected = tasmota.wifi('up') && (tasmota.wifi('ip') || tasmota.wifi('ip6local'))
        if (wifiConnected != prev_wifiConnected)
            prev_wifiConnected = wifiConnected
            if !wifiConnected
                self.reset_ip()
            elif wifiConnected
                self.set_ip()
                self.get_location()
                self.set_forecast()
                self.set_date()
                self.set_clock()
            end
        end
    end

    def every_second()
        if self.tcp_client && self.connection != false
            if self.tcp_client.connected() == false
                self.connection = false
                self.tcp_client.close()
            end
        end
        self.refresh_page()
        if !wifiConnected
            tempSec += 1
            if(tempSec >= 50)
                tempSec = 0
                tasmota.cmd("Status 10")   
            end
        end
    end

    def every_15_s()
        self.set_clock()
        self.set_date()           
    end

    def every_8_h()
        self.set_forecast()
        if(_currentPageId == 0)
            self.init_component(_currentPageId)
        end
    end

    def every_day()
        self.set_date()
    end

    def create_server()
        if wifiConnected
            self.ts = tcpserver(4080)
        end
    end

    def nssend(msg)
        if self.connection == true
            self.tcp_client.write(msg)
        end
    end

    def nsloop()
        if self.connection == true
            import json
            if self.tcp_client.available()
                var msg = self.tcp_client.read()
                self.inParameter = 0
                var data_msg = json.load(msg)
                if size(data_msg) == 0 || data_msg == nil || data_msg == 'nil'
                    return 
                end
                voltage = data_msg["Vol"]
                current = data_msg['Cur']
                power = data_msg['Pow']
                tempCooler = data_msg['Temp']
                tempBoiler = data_msg['Temp_B']
                dayEnergy = data_msg['DE']
                if data_msg['TE'] != nil && data_msg['TE'] != "" 
                    totalEnergy = data_msg['TE']
                end
                regulatorIP = data_msg['IP']
                mode = data_msg['Mod']
                relayAC = data_msg['RL']
                if data_msg['HW'] != nil && data_msg['HW'] != "" 
                    versionHW = data_msg['HW']
                    var components = widget["4"][2][2]
                    components[2].setitem(5,versionHW )
                end
                if data_msg['SW'] != nil && data_msg['SW'] != "" 
                    versionSW = data_msg['SW']
                    var components = widget["4"][2][2]
                    components[3].setitem(5,versionSW )
                end
                self.dzd_regulator_widget()
                self.wait_refresh = false
            end
        end
    end

    def dzd_regulator_widget()
        var components = widget["1"][2][2]
        components[0].setitem(5,str(voltage))
        components[0].setitem(6,"V")
        components[1].setitem(5,str(current))
        components[1].setitem(6,"mA")
        components[2].setitem(5,str(power))
        components[2].setitem(6,"W")
        components[3].setitem(5,str(tempCooler))
        components[3].setitem(6,"°C")
        components = widget["2"][2][2]
        components[0].setitem(5,str(dayEnergy))
        components[0].setitem(6,"Wh")
        components[1].setitem(5,str(totalEnergy))
        components[1].setitem(6,"Wh")
        components[2].setitem(5,str(tempBoiler))
        components[2].setitem(6,"°C")
        self.set_ip2()
        var comp = widget["3"][2][2]
        comp[0].setitem(5, mode ? "1" : "0")
        comp[0].setitem(4,mode ? self.obtain_string("Turn on") : self.obtain_string("Turn off"))

        comp[1].setitem(5, str(relayAC))
        comp[1].setitem(4, relayAC ? self.obtain_string("Relay on") : self.obtain_string("Relay off"))
    end

    def dzd_regulator_page_null()
        var components = widget["1"][2][2]
        for i: 0..3
            components[i].setitem(5,"nodata")
            components[i].setitem(6,"")
        end
        
        var component = widget["2"][2][2]
        for j: 0..2
            component[j].setitem(5,"nodata")
            component[j].setitem(6,"")
        end
        regulatorIP = ""
        self.set_ip2()
        var comp = widget["3"][2][2]
        comp[0].setitem(5, "0")
        comp[0].setitem(4, self.obtain_string("Turn off"))
        comp[1].setitem(5, "0")
        comp[1].setitem(4, self.obtain_string("Relay off"))
        comp = widget["4"][2][2]
        comp[2].setitem(5, "")
        comp[3].setitem(5, "")
    end

    def init_heaters()
        widget[self.get_page_id("cardThermo")][2][2][0].setitem(2,targetTemp)
        widget[self.get_page_id("cardThermo")][2][2][0].setitem(4,minTemp)
        widget[self.get_page_id("cardThermo")][2][2][0].setitem(5,maxTemp)
        widget[self.get_page_id("cardThermo")][2][2][0].setitem(6,tempStep)
        if hvac_mode == "heat"
            solo_operate_nspanel_relay1 = false
        elif hvac_mode == "off"
            solo_operate_nspanel_relay1 = true
        end
    end

    def init_nspanel_relays()
        var status = tasmota.get_power()[0]
        self.set_nspanel_relay1(status ? "1" : "0")
        status = tasmota.get_power()[1]
        self.set_nspanel_relay2(status ? "1" : "0")
    end

    def init_widget()
        self.init_heaters()
        self.init_nspanel_relays()
        widget["6"][2][2][2].setitem(5,str(_sleepTimeout)+sleepMaxMin)
    end

    def set_temperature(value)
        try temperatureInternal = value
        except 'key_error'
            print("key_error in set_temperature")
            temperatureInternal = 0
        end
        if temperatureInternal == nil
            temperatureInternal = 0
        end
        widget[self.get_page_id("screensaver")][2][2][0].setitem(5,str(temperatureInternal))
        widget[self.get_page_id("cardThermo")][2][2][0].setitem(1,str(temperatureInternal) + " °C")
        var pageIdTxt  = str(_currentPageId)
        if(widget[pageIdTxt][0] == "cardThermo" || widget[pageIdTxt][0] == "screensaver")
            self.init_component(_currentPageId)
        end
        self.run_hysteresis()
    end

    def set_ip()
        if wifiConnected
            self.ip_own = tasmota.wifi()['ip']
            var components = widget["4"][2][2]
            components[0].setitem(5,self.ip_own)
        end
    end

    def reset_ip()
        var components = widget["4"][2][2]
        components[0].setitem(5," ")
    end

    def set_ip2()
        var components = widget["4"][2][2]
        components[1].setitem(5,regulatorIP)
    end

    def set_statusIcons()
        tempVal += 1
        if(tempVal >= 10)
            tempVal = 0
            var wifiConnection 
            var rssi
            if wifiConnected
                var wifiQuality = tasmota.wifi('quality')
                if wifiQuality != nil
                    if wifiQuality >= 75
                        wifiConnection = wifiIcon["4"]
                    elif wifiQuality >= 50 && wifiQuality < 75
                        wifiConnection = wifiIcon["3"]
                    elif wifiQuality >= 25 && wifiQuality < 50
                        wifiConnection = wifiIcon["2"]
                    elif wifiQuality >= 0 && wifiQuality < 25
                        wifiConnection = wifiIcon["1"]
                    end
                else 
                    wifiConnection = wifiIcon["5"] 
                end
            else
                wifiConnection = wifiIcon["0"]
            end
            rssi = tasmota.wifi('rssi')
            if rssi == nil 
                rssi  = " "
            end
            var regulatorStatus
            if self.connection == false
                regulatorStatus = "0"
            elif int(power) <= 2 || int(widget["3"][2][2][0][5]) == 0
                regulatorStatus = "65504"
            elif int(power) > 2
                regulatorStatus = "1024"
            end
            self.send("statusUpdate~" + wifiConnection + " " + str(rssi) + "~17299~~" + regulatorStatus + "~~1~")
        end
    end

    def run_hysteresis()
        var iconColor = ""
        var status    = ""
        var val
        if hvac_mode == "heat"
            if temperatureInternal + real(hysteresis) > (real(targetTemp)/10)
                if select_language == "en"
                    status = "        "+"Idle"+"              "+"(" +"Heat" +")"
                elif select_language == "cs"
                    status = "     "+"Nečinný"+"          "+"(" +"Teplo" +")"
                end
                tasmota.set_power(0, false)
                self.set_nspanel_relay1("0")
            elif temperatureInternal + real(hysteresis) <= real(targetTemp)/10
                if select_language == "en"
                    status = "     "+"Heating"+"          "+"("+"Heat"+")"
                elif select_language == "cs"
                    status = "       "+"Topí"+"             "+"("+"Teplo"+")"
                end
                tasmota.set_power(0, true)
                self.set_nspanel_relay1("1")
            end
            iconColor = "64512"
            val = "1"
        elif hvac_mode == "off"
            if solo_operate_nspanel_relay1 == false
                tasmota.set_power(0, false)
                self.set_nspanel_relay1("0")
            end
            solo_operate_nspanel_relay1 = true            
            status = "        "+"Off"+"                "+"("+"Off"+")"
            iconColor = "35921"
            val = "0"
        end
        var thermoPage = widget[self.get_page_id("cardThermo")][2][2][6]
        thermoPage.setitem(0, iconAll["fire"])
        thermoPage.setitem(1, iconColor)
        thermoPage.setitem(2, val)
        thermoPage.setitem(3, "heater1")
        widget[self.get_page_id("cardThermo")][2][2][0].setitem(3, status)

        var pageIdTxt  = str(_currentPageId)
        if pageIdTxt == self.get_page_id("cardThermo")
            self.init_component(_currentPageId)
        end
    end

    def set_forecast()
        if wifiConnected
            import json
            var wc = webclient()
            var url = "http://wttr.in/" + loc + "?format=j2"
            wc.set_useragent("curl/7.72.0")
            wc.set_follow_redirects(true)
            wc.begin(url)
            var status = wc.GET()
            if status == 200 || status == "200"
                var b = json.load(wc.get_string())
                var components = widget[self.get_page_id("screensaver")][2][2]
                components[1].setitem(2, weather_icon[str(b['current_condition'][0]['weatherCode'])])
                components[5].setitem(2, weather_icon[str(b['current_condition'][0]['weatherCode'])])
                components[5].setitem(5, b['current_condition'][0]['temp_C'])
                components[5].setitem(6, '°C')
                var today = self.set_date()['weekday']
                for i:0..2
                    components[i+1].setitem(4, nickname_weekdays[today+i>6 ? (today+i)-7 : today+i])
                    components[i+1].setitem(5, b['weather'][i]['avgtempC'])
                    components[i+1].setitem(6, '°C')
                end
            else log("wttr: %s",status)
            end
        end
    end

    def get_location()
        if wifiConnected
            var wc = webclient()
            wc.begin(addr_get_location)
            var status = wc.GET()
            import json
            var data = json.load(wc.get_string())
            wc.close()
            latitude = data['latitude']
            log(string.format("latitude: %s" ,latitude))
            longitude = data['longitude']
            log(string.format("longitude: %s" ,longitude))
            try loc = data["city"]
            except 'key_error'
                return
            end
            loc = string.replace(loc," ","+")
        end
    end

    def refresh_page()
        if _currentPageId != 0 && _currentPageId != 5 && self.wait_refresh == false
            self.init_component(_currentPageId)
        end
    end

    def init_mdns()
        if wifiConnected
            import mdns
            mdns.start()
            mdns.set_hostname("SEco-NSpanel")
        end
    end

    def init_language()
        # self.strings_translate = self.load_file('strings_translate.json')
        self.strings_translate = {
        "en":{
            "vítejte": "Welcome", 
            "solareco regulátor": "SolarEco regulator",
            "ovládání topení": "Heater control",
            "napětí":"Voltage",
            "proud":"Current",
            "výkon":"Power",
            "teplota chladiče":"Cooler temp",
            "denní výroba":"Day energy",
            "celková výroba":"Total energy",
            "teplota bojleru":"Boiler Temp",
            "vypnout":"Turn off",
            "zapnout":"Turn on",
            "relé on":"Relay on",
            "relé off":"Relay off",
            "displej":"Display",
            "regulátor":"Regulator",
            "hardware":"Hardware",
            "software":"Software",
            "pon":"Mon",
            "úte":"Tue",
            "Úte":"Tue",
            "stř":"Wed",
            "čtv":"Thu",
            "Čtv":"Thu",
            "pát":"Fri",
            "sob":"Sat",
            "ned":"Sun",
            "pondělí":"Monday",
            "úterý":"Tuesday",
            "Úterý":"Tuesday",
            "středa":"Wednesday",
            "čtvrtek":"Thursday",
            "Čtvrtek":"Thursday",
            "pátek":"Friday",
            "sobota":"Saturday",
            "neděle":"Sunday",
            "leden":"January",
            "únor":"February",
            "Únor":"February",
            "březen":"March",
            "duben":"April",
            "květen":"May",
            "červen":"June",
            "Červen":"June",
            "červenec":"July",
            "Červenec":"July",
            "srpen":"August",
            "září":"September",
            "říjen":"October",
            "Říjen":"October",
            "listopad":"November",
            "prosinec":"December",
            "nastavení":"Settings",
            "ohřívač": "heater",
            "aktuální": "Currently",
            "stav": "Status",
            "teplo": "Heat",
            "nečinný": "Idle",
            "topí": "Heating",
            "restartovat": "Restart",
            "jazyk": "Language",
            "spaní (s)": "Sleep (s)",

            "en":"English",
            "cs":"Czech",
            "Český":"Czech",
            "český":"Czech",   
            "welcome": "Welcome", 
            "solareco regulator": "SolarEco regulator",
            "heater control": "Heater control",
            "voltage":"Voltage",
            "current":"Current",
            "power":"Power",
            "cooler temp":"Cooler temp",
            "day energy":"Day energy",
            "total energy":"Total energy",
            "boiler temp":"Boiler Temp",
            "turn off":"Turn off",
            "turn on":"Turn on",
            "relay on":"Relay on",
            "relay off":"Relay off",
            "display":"Display",
            "regulator":"Regulator",
            "mon":"Mon",
            "tue":"Tue",
            "wed":"Wed",
            "thu":"Thu",
            "fri":"Fri",
            "sat":"Sat",
            "sun":"Sun",
            "monday":"Monday",
            "tuesday":"Tuesday",
            "wednesday":"Wednesday",
            "thursday":"Thursday",
            "friday":"Friday",
            "saturday":"Saturday",
            "sunday":"Sunday",
            "january":"January",
            "february":"February",
            "march":"March",
            "april":"April",
            "may":"May",
            "june":"June",
            "july":"July",
            "august":"August",
            "september":"September",
            "october":"October",
            "november":"November",
            "december":"December",
            "setting":"Setting",
            "settings":"Settings",
            "language":"Language",
            "heater": "Heater",
            "currently": "Currently",
            "status": "Status",
            "heat": "Heat",
            "idle": "Idle",
            "heating": "Heating",
            "restart": "Restart",
            "english": "Česky",
            "lout-1": "LOut-1",
            "lout-2": "LOut-2",
            "sleep (s)": "Sleep (s)"
        },
        "cs":{
            "welcome": "Vítejte",
            "solareco regulator": "SolarEco Regulátor",
            "heater control": "Ovládání topení",
            "voltage":"Napětí",
            "current":"Proud",
            "power":"Výkon",
            "cooler temp":"Teplota chladiče",
            "day energy":"Denní výroba",
            "total energy":"Celková výroba",
            "boiler temp":"Teplota bojleru",
            "turn off":"Vypnout",
            "turn on":"Zapnout",
            "relay on":"Relé on",
            "relay off":"Relé off",
            "display":"Displej",
            "regulator":"Regulátor",
            "hardware":"Hardware",
            "software":"Software",
            "mon":"Pon",
            "tue":"Úte",
            "wed":"Stř",
            "thu":"Čtv",
            "fri":"Pát",
            "sat":"Sob",
            "sun":"Ned",
            "monday":"Pondělí",
            "tuesday":"Úterý",
            "wednesday":"Středa",
            "thursday":"Čtvrtek",
            "friday":"Pátek",
            "saturday":"Sobota",
            "sunday":"Neděle",
            "january":"Leden",
            "february":"Únor",
            "march":"Březen",
            "april":"Duben",
            "may":"Květen",
            "june":"Červen",
            "july":"Červenec",
            "august":"Srpen",
            "september":"Září",
            "october":"Říjen",
            "november":"Listopad",
            "december":"Prosinec",
            "settings":"Nastavení",
            "en":"Anglický",
            "cs":"Český",
            "jazyk":"Jazyk",
            "language":"Jazyk",
            "heater": "Ohřívač",
            "currently": "Aktuální",
            "status": "Stav",
            "heat": "Teplo",
            "idle": "Nečinný",
            "heating": "Topí",
            "restart": "Restartovat",
            "english": "English",
            "lout-1": "LOut-1",
            "lout-2": "LOut-2",
            "sleep (s)": "Spaní (s)",
            "Česky": "English",
            "česky": "English"

        }
    }
    end

    def load_file(fn)
        var f, strings_translate
        f = open(fn, "r")
        strings_translate = json.load(f.read())
        f.close()
        return strings_translate
    end

    def set_language(lang)
        if self.strings_translate.contains(lang)
            import persist
            select_language = lang
            persist.select_language = select_language
            persist.save()
            widget["6"][2][2][0].setitem(2, iconAll[select_language])
            widget["6"][2][2][0].setitem(4, self.obtain_string(widget["6"][2][2][0][4]))
        else
            print("Language not supported.")
        end
    end

    def obtain_string(key)                               
        import string
        return self.strings_translate[select_language][string.tolower(key)]
    end

    def translate_static_strings()
        for i:widget
            if i[2][0] != []
                i[2][0].setitem(0,self.obtain_string(i[2][0][0]))
            end
            for j:i[2][2]
                if j[4] != "" && j[4] != "0"
                    j.setitem(4,self.obtain_string(j[4]))
                end
                if j[0] == "button" && j[5] != ""
                    j.setitem(5,self.obtain_string(j[5]))
                end          
            end
            if i[0] == "cardThermo"
                i[2][2][9].setitem(0, self.obtain_string(i[2][2][9][0]))
                i[2][2][9].setitem(1, self.obtain_string(i[2][2][9][1]))
            end
        end
    end

    def set_nspanel_relay1(status)
        widget["3"][2][2][2].setitem(5, str(status))
        self.send("resetSleepValue~0")
    end

    def set_nspanel_relay2(status)
        widget["3"][2][2][3].setitem(5, str(status))
        self.send("resetSleepValue~0")
    end

    def set_sleepTime(value_sleepTime)
        _sleepTimeout = value_sleepTime
        persist._sleepTimeout = str(_sleepTimeout)
        persist.save()
        widget["6"][2][2][2].setitem(5,str(_sleepTimeout)+sleepMaxMin)
        self.send("timeout~"+str(_sleepTimeout))
    end

    def write_block()
        log("FLH: Read block",3)
        while size(self.flash_buff)<self.flash_block_size && self.tcp.connected()
            if self.tcp.available()>0
                self.flash_buff += self.tcp.readbytes(4096)
            else
                tasmota.delay(50)
                log("FLH: Wait for available...",3)
            end
        end
        log("FLH: Buff size "+str(size(self.flash_buff)),3)
        var to_write
        if size(self.flash_buff)>self.flash_block_size
            to_write = self.flash_buff[0..self.flash_block_size-1]
            self.flash_buff = self.flash_buff[self.flash_block_size..]
        else
            to_write = self.flash_buff
            self.flash_buff = bytes()
        end
        log("FLH: Writing "+str(size(to_write)),3)
        var per = (self.flash_written*100)/self.flash_size
        if (self.last_per!=per) 
            self.last_per = per
            tasmota.publish_result(string.format("{\"Flashing\":{\"complete\": %d, \"time_elapsed\": %d}}",per , (tasmota.millis()-self.flash_start_millis)/1000), "RESULT") 
        end
        if size(to_write)>0
            self.flash_written += size(to_write)
            self.ser.write(to_write)
        end
        log("FLH: Total "+str(self.flash_written),3)
        if (self.flash_written==self.flash_size)
            log("FLH: Flashing complete - Time elapsed: %d", (tasmota.millis()-self.flash_start_millis)/1000)
            self.flash_mode = 0
            self.ser.deinit()
            self.ser = serial(17, 16, 115200, serial.SERIAL_8N1)
        end
    end

    def every_100ms()
        if self.ser.available() > 0
            var msg = self.ser.read()
            if size(msg) > 0
                log(string.format("NXP: Received Raw = %s",str(msg)), 3)
                if (self.flash_mode==1)
                    var strv = msg[0..-4].asstring()
                    if string.find(strv,"comok 2")>=0
                        tasmota.delay(50)
                        log("FLH: Send (High Speed) flash start")
                        self.flash_start_millis = tasmota.millis()
                        #self.sendnx(string.format("whmi-wris %d,115200,res0",self.flash_size))
                        if self.flash_proto_version == 0
                            self.sendnx(string.format("whmi-wri %d,%d,res0",self.flash_size,self.flash_proto_baud))
                        else
                            self.sendnx(string.format("whmi-wris %d,%d,res0",self.flash_size,self.flash_proto_baud))
                        end
                        if self.flash_proto_baud != 115200
                            tasmota.delay(50)
                            self.ser.deinit()
                            self.ser = serial(17, 16, self.flash_proto_baud, serial.SERIAL_8N1)
                        end
                    elif size(msg)==1 && msg[0]==0x08
                        log("FLH: Waiting offset...",3)
                        self.awaiting_offset = 1
                    elif size(msg)==4 && self.awaiting_offset==1
                        self.awaiting_offset = 0
                        self.flash_offset = msg.get(0,4)
                        log("FLH: Flash offset marker "+str(self.flash_offset),3)
                        if self.flash_offset != 0
                            self.open_url_at(self.url, self.flash_offset)
                            self.flash_written = self.flash_offset
                        end
                        self.write_block()
                    elif size(msg)==1 && msg[0]==0x05
                        self.write_block()
                    else
                        log("FLH: Something has gone wrong flashing display firmware ["+str(msg)+"]",2)
                    end
                else
                    var msg_list = self.split_55(msg)
                    for i:0..size(msg_list)-1
                        msg = msg_list[i]
                        if size(msg) > 0
                            if msg == bytes('000000FFFFFF88FFFFFF')
                                self.screeninit()
                            elif size(msg)>=2 && msg[0]==0x55 && msg[1]==0xBB
                                var jm = string.format("{\"CustomRecv\":\"%s\"}",msg[4..-3].asstring())
                                self.parse_from_nextion(msg[4..-3].asstring());
                                tasmota.publish_result(jm, "RESULT")        
                            elif msg[0]==0x07 && size(msg)==1 # BELL/Buzzer
                                tasmota.cmd("buzzer 1,1")
                            else
                                var jm = string.format("{\"nextion\":\"%s\"}",str(msg[0..-4]))
                                tasmota.publish_result(jm, "RESULT")        
                            end
                        end       
                    end
                end
            end
        end
        if(startup == true)
            m100Sec += 100
            if (m100Sec/1000) >= _sleepTimeout
                startup = false
                doubleTapToUnlock = true
                self.send("dimmode~10~100~6371")
                self.set_clock()
                self.init_page(self.get_page_id("screensaver"))
                self.set_statusIcons()
            end
        end
    end      

    def begin_nextion_flash()
        self.flash_written = 0
        self.awaiting_offset = 0
        self.flash_offset = 0
        self.sendnx('DRAKJHSUYDGBNCJHGJKSHBDN')
        self.sendnx('recmod=0')
        self.sendnx('recmod=0')
        self.flash_mode = 1
        self.sendnx("connect")        
    end
    
    def open_url_at(url, pos)
        self.url = url
        var host
        var port
        var s1 = string.split(url,7)[1]
        var i = string.find(s1,":")
        var sa
        if i<0
            port = 80
            i = string.find(s1,"/")
            sa = string.split(s1,i)
            host = sa[0]
        else
            sa = string.split(s1,i)
            host = sa[0]
            s1 = string.split(sa[1],1)[1]
            i = string.find(s1,"/")
            sa = string.split(s1,i)
            port = int(sa[0])
        end
        var get = sa[1]
        log(string.format("FLH: host: %s, port: %s, get: %s",host,port,get))
        self.tcp = tcpclient()
        self.tcp.connect(host,port)
        log("FLH: Connected:"+str(self.tcp.connected()),3)
        var get_req = "GET "+get+" HTTP/1.0\r\n"
        get_req += string.format("Range: bytes=%d-\r\n", pos)
        get_req += string.format("HOST: %s:%s\r\n\r\n",host,port)
        self.tcp.write(get_req)
        var a = self.tcp.available()
        i = 1
        while a==0 && i<5
          tasmota.delay(100*i)
          tasmota.yield() 
          i += 1
          log("FLH: Retry "+str(i),3)
          a = self.tcp.available()
        end
        if a==0
            log("FLH: Nothing available to read!",3)
            return
        end
        var b = self.tcp.readbytes()
        i = 0
        var end_headers = false;
        var headers
        while i<size(b) && headers==nil
            if b[i..(i+3)]==bytes().fromstring("\r\n\r\n") 
                headers = b[0..(i+3)].asstring()
                self.flash_buff = b[(i+4)..]
            else
                i += 1
            end
        end
        #print(headers)
        # check http respose for code 200/206
        if string.find(headers,"200 OK")>0 || string.find(headers,"206 Partial Content")>0
            log("FLH: HTTP Respose is 200 OK or 206 Partial Content",3)
        else
            log("FLH: HTTP Respose is not 200 OK or 206 Partial Content",3)
            print(headers)
            return -1
        end
        # only set flash size if pos is zero
        if pos == 0
            # check http respose for content-length
            var tag = "Content-Length: "
            i = string.find(headers,tag)
            if (i>0) 
                var i2 = string.find(headers,"\r\n",i)
                var s = headers[i+size(tag)..i2-1]
                self.flash_size=int(s)
            end
            log("FLH: Flash file size: "+str(self.flash_size),3)
        end

    end

    def flash_nextion(url)
        self.flash_size = 0
        var res = self.open_url_at(url, 0)
        if res != -1
            self.begin_nextion_flash()
        end
    end

    def init()
        log("NXP: Initializing Driver")
        self.ser = serial(17, 16, 115200, serial.SERIAL_8N1)
        self.flash_mode = 0
        self.flash_proto_version = 1
        self.flash_proto_baud = 921600
        tasmota.cmd("Backlog0 Timezone 99; TimeStd 0,0,10,1,3,60; TimeDst 0,0,3,1,2,120")
        tasmota.add_cron("*/15 * * * * *", /-> self.every_15_s(), "every_15_s")
        tasmota.add_cron("0 0 1 * * *", /-> self.every_day(), "every_day")
        tasmota.add_cron("0 0 */8 * * *", /-> self.every_8_h(), "every_8_h")
        tasmota.add_rule("Tele#ANALOG#Temperature1", / value -> tasmota.set_timer(0, / -> self.set_temperature(value)))
        tasmota.add_rule("StatusSNS#ANALOG#Temperature1", / value -> tasmota.set_timer(0, / -> self.set_temperature(value)))
        tasmota.add_rule("power1#state", / value -> tasmota.set_timer(0, / -> self.set_nspanel_relay1(value)))
        tasmota.add_rule("power2#state", / value -> tasmota.set_timer(0, / -> self.set_nspanel_relay2(value)))
        # tasmota.add_rule("system#boot", /-> self.boot_init())
        tasmota.cmd("Status 10")
        tasmota.cmd("DeviceName SolarEco")
        self.connection = false
        self.inParameter = 0
        self.wait_refresh = false
        self.setStatusButton = 0
        self.init_widget()
        self.init_language()
        tasmota.add_driver(self)
    end
end

var nextion = Nextion()

# tasmota.add_driver(nextion)

def get_current_version(cmd, idx, payload, payload_json)
    var version_of_this_script = 9
    var jm = string.format("{\"nlui_driver_version\":\"%s\"}", version_of_this_script)
    tasmota.publish_result(jm, "RESULT")
end

tasmota.add_cmd('GetDriverVersion', get_current_version)

def update_berry_driver(cmd, idx, payload, payload_json)
    def task()
        import path
		if string.find(payload, ".tapp") > 0
		    print("tapp in URL; will do .tapp update and migration if necessary")
			
			if path.exists("autoexec.be")
			    print("autoexec.be found; will check for migration")
				var autoexecfile = open('autoexec.be')
				var line = autoexecfile.readline()
				autoexecfile.close()
				if string.find(line, "NSPanel Tasmota Lovelace UI Berry Driver") > 0
			        print("found lovelace berry driver, going to delete autoexec.be and .bec")
					path.remove("autoexec.be")
					path.remove("autoexec.bec")
				end
			end
			
			var r = tasmota.urlfetch(payload, "nsp-lovelace-driver.tapp")
            if r < 0
                print("Update failed")
            else
                tasmota.cmd("Restart 1")
            end
			
		elif string.find(payload, ".be") > 0
		    print("be in URL; will do .be update")
			if path.exists("nsp-lovelace-driver.tapp")
			    print("Error: there is the tapp version of the berry driver installed; cannot do .be update.")
			else
                var cl = webclient()
                cl.begin(payload)
                var r = cl.GET()
                if r == 200
                    print("Sucessfully downloaded nspanel-lovelace-ui berry driver")
                else
                    print("Error while downloading nspanel-lovelace-ui berry driver")
                end
                r = cl.write_file("autoexec.be")
                if r < 0
                    print("Error while writeing nspanel-lovelace-ui berry driver")
                else
                    print("Sucessfully written nspanel-lovelace-ui berry driver")
                    tasmota.cmd("Restart 1")
                end
			end
		else
			print("invalid url filetype")
		end
		
		
		
        if path.exists("nsp-lovelace-driver.tapp")
            var r = string.find(payload, ".tapp")
            if r < 0
                print("URL doesn't contain .tapp skipping update")
            else

            end
        else
            var r = string.find(payload, ".be")
            if r < 0
                print("URL doesn't contain .be skipping update")
            else
        
            end                
        end
    end
    tasmota.set_timer(0,task)
    tasmota.resp_cmnd_done()
end

tasmota.add_cmd('UpdateDriverVersion', update_berry_driver)

def flash_nextion(cmd, idx, payload, payload_json)
    def task()
    nextion.flash_proto_version = 1
    nextion.flash_proto_baud = 921600
        nextion.flash_nextion(payload)
    end
    tasmota.set_timer(0,task)
    tasmota.resp_cmnd_done()
end

def flash_nextion_adv(cmd, idx, payload, payload_json)
    def task()        
        if idx==0
            nextion.flash_proto_version = 1
            nextion.flash_proto_baud = 921600
        elif idx==1
            nextion.flash_proto_version = 0
            nextion.flash_proto_baud = 921600
        elif idx==2
            nextion.flash_proto_version = 1
            nextion.flash_proto_baud = 115200
        elif idx==3
            nextion.flash_proto_version = 0
            nextion.flash_proto_baud = 115200
        elif idx==4
            nextion.flash_proto_version = 1
            nextion.flash_proto_baud = 256000
        elif idx==5
            nextion.flash_proto_version = 0
            nextion.flash_proto_baud = 256000
        elif idx==6
            nextion.ser.deinit()
            nextion.ser = serial(17, 16, 9600, serial.SERIAL_8N1)
            nextion.flash_proto_version = 0
            nextion.flash_proto_baud = 921600
        else
            nextion.flash_proto_version = 0
            nextion.flash_proto_baud = 115200
        end
        
        nextion.flash_nextion(payload)
    end
    tasmota.set_timer(0,task)
    tasmota.resp_cmnd_done()
end

def send_cmd(cmd, idx, payload, payload_json)
    nextion.sendnx(payload)
    tasmota.resp_cmnd_done()
end

def send_cmd2(cmd, idx, payload, payload_json)
    nextion.send(payload)
    tasmota.resp_cmnd_done()
end

tasmota.add_cmd('Nspanel', send_cmd)
tasmota.add_cmd('CustomSendNspanel', send_cmd2)
tasmota.add_cmd('FlashNspanel', flash_nextion)
tasmota.add_cmd('FlashNspanelAdv', flash_nextion_adv)
