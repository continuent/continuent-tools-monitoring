module TungstenNagiosMonitor
  NAGIOS_OK=0
  NAGIOS_WARNING=1
  NAGIOS_CRITICAL=2
  
  def configure
    super()
    
    opt(:nagios_status_sent, false)
    @perfdata = []
    
    if uses_nagios_comparison_levels?()
      add_option(:warning_level, {
        :on => "-w String",
        :help => "The warning level for this monitor"
      })
    
      add_option(:critical_level, {
        :on => "-c String",
        :help => "The critical level for this monitor"
      })
    end
  end
  
  def uses_nagios_comparison_levels?
    false
  end
  
  def add_perfdata(key, value)
    @perfdata << "#{key}=#{value};"
  end
  
  def perfdata
    @perfdata.join(" ")
  end
  
  def nagios_ok(msg)
    opt(:nagios_status_sent, true)
    puts "OK: #{msg} | #{perfdata()}"
    cleanup(NAGIOS_OK)
  end
  
  def nagios_warning(msg)
    opt(:nagios_status_sent, true)
    puts "WARNING: #{msg} | #{perfdata()}"
    cleanup(NAGIOS_WARNING)
  end
  
  def nagios_critical(msg)
    opt(:nagios_status_sent, true)
    puts "CRITICAL: #{msg} | #{perfdata()}"
    cleanup(NAGIOS_CRITICAL)
  end
  
  def cleanup(code = 0)
    if opt(:nagios_status_sent) == false
      if code == 0
        puts "OK: No errors | #{perfdata()}"
        code = NAGIOS_OK
      else
        puts "CRITICAL: Errors were encountered while running this script | #{perfdata()}"
        code = NAGIOS_CRITICAL
      end
    end
    
    super(code)
  end
end