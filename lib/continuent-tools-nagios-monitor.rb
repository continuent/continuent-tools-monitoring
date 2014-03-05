module TungstenNagiosMonitor
  NAGIOS_OK=0
  NAGIOS_WARNING=1
  NAGIOS_CRITICAL=2
  NAGIOS_UNKNOWN=3
  
  # This script supports the warning (-w) and critical (-c) arguments. 
  # Override this function to return true if you would like to use
  # those arguments.
  def uses_thresholds?
    false
  end
  
  # Compare the value to the collected threshold values as floats
  def check_threshold(value)
    unless value.to_s() =~ /^[0-9\.]+$/
      unknown("Unable to compare a non-numeric value : #{value}")
    end
    
    check = value.to_s().to_f()
    if check >= opt(:critical_level).to_f()
      critical(build_critical_message(value))
    elsif check >= opt(:warning_level).to_f()
      warning(build_warning_message(value))
    else
      ok(build_ok_message(value))
    end
  end
  
  # Build an output string when the value has passed
  def build_ok_message(value)
    "Value is OK (#{value})"
  end
  
  # Build an output string when the value is at a warning level
  def build_warning_message(value)
    "Value is too high (#{value})"
  end
  
  # Build an output string when the value is critical
  def build_critical_message(value)
    "Value is too high (#{value})"
  end
  
  # Add a key=>value pair to the performance data
  def add_perfdata(key, value)
    @perfdata << "#{key}=#{value};"
  end
  
  # Return a Nagios-formatted performance data string
  def perfdata
    @perfdata.join(" ")
  end
  
  # Output a Nagios-formatted success return message and return the 
  # OK code
  def ok(msg)
    opt(:nagios_status_sent, true)
    TU.output "OK: #{msg} | #{perfdata()}"
    cleanup(NAGIOS_OK)
  end
  
  # Output a Nagios-formatted warning return message and return the 
  # warning code
  def warning(msg)
    opt(:nagios_status_sent, true)
    TU.output "WARNING: #{msg} | #{perfdata()}"
    cleanup(NAGIOS_WARNING)
  end
  
  # Output a Nagios-formatted critical return message and return the 
  # critical code
  def critical(msg)
    opt(:nagios_status_sent, true)
    TU.output "CRITICAL: #{msg} | #{perfdata()}"
    cleanup(NAGIOS_CRITICAL)
  end
  
  # Output a Nagios-formatted unknown return message and return the 
  # unknown code
  def unknown(msg)
    opt(:nagios_status_sent, true)
    TU.output "UNKNOWN: #{msg} | #{perfdata()}"
    cleanup(NAGIOS_UNKNOWN)
  end
  
  private
  
  def configure
    super()
    
    opt(:nagios_status_sent, false)
    @perfdata = []
    
    if uses_thresholds?()
      add_option(:warning_level, {
        :on => "-w String",
        :help => "The warning level for this monitor",
        :required => true,
      })
    
      add_option(:critical_level, {
        :on => "-c String",
        :help => "The critical level for this monitor",
        :required => true,
      })
    end
  end
  
  def cleanup(code = 0)
    if opt(:nagios_status_sent) == false
      if code == 0
        TU.output "OK: No errors | #{perfdata()}"
        code = NAGIOS_OK
      else
        TU.output "UNKNOWN: Errors were encountered while running this script | #{perfdata()}"
        code = NAGIOS_UNKNOWN
      end
    end
    
    super(code)
  end
end