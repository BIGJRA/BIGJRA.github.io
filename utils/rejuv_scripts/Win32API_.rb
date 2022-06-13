class Win32API
=begin
  def pbSetWindowText(text)
    hWnd = pbFindRgssWindow
    swp = Win32API.new('user32','SetWindowTextA',%(l, p),'i')
    swp.call(hWnd, text.to_s)
  end

 # Added by Peter O. as a more reliable way to get the RGSS window
  def Win32API.pbFindRgssWindow
    return @@RGSSWINDOW if @@RGSSWINDOW
    processid = [0].pack('l')
    threadid = @@GetCurrentThreadId.call
    nextwindow = 0
    begin
      nextwindow = @@FindWindowEx.call(0,nextwindow,"RGSS Player",0)
      if nextwindow!=0
        wndthreadid = @@GetWindowThreadProcessId.call(nextwindow,processid)
        if wndthreadid==threadid
          @@RGSSWINDOW = nextwindow
          return @@RGSSWINDOW 
        end
      end
    end until nextwindow==0
    raise "Can't find RGSS player window"
    return 0
  end
=end
  def Win32API.SetWindowPos(w, h)
    hWnd = pbFindRgssWindow
    windowrect = Win32API.GetWindowRect
    clientsize = Win32API.client_size
    xExtra = windowrect.width-clientsize[0]
    yExtra = windowrect.height-clientsize[1]
    swp = Win32API.new('user32','SetWindowPos',%(l,l,i,i,i,i,i),'i')
    win = swp.call(hWnd,0,windowrect.x,windowrect.y,w+xExtra,h+yExtra,0)
    return win
  end

  def Win32API.client_size
    hWnd = pbFindRgssWindow
    rect = [0,0,0,0].pack('l4')
    Win32API.new('user32','GetClientRect',%w(l p),'i').call(hWnd,rect)
    width,height = rect.unpack('l4')[2..3]
    return width,height
  end

  def Win32API.GetWindowRect
    hWnd = pbFindRgssWindow
    rect = [0,0,0,0].pack('l4')
    Win32API.new('user32','GetWindowRect',%w(l p),'i').call(hWnd,rect)
    x,y,width,height = rect.unpack('l4')
    return Rect.new(x,y,width-x,height-y)
  end

  def Win32API.focusWindow
    window = Win32API.new('user32','ShowWindow','LL','L')
    hWnd = pbFindRgssWindow
    window.call(hWnd,9)
  end
 
  def Win32API.fillScreen
    setWindowLong = Win32API.new('user32','SetWindowLong','LLL','L')
    setWindowPos  = Win32API.new('user32','SetWindowPos','LLIIIII','I')
    metrics = Win32API.new('user32', 'GetSystemMetrics', 'I', 'I')
    hWnd = pbFindRgssWindow
    width  = metrics.call(0)
    height = metrics.call(1)
    setWindowLong.call(hWnd,-16,0x00000000)
    setWindowPos.call(hWnd,0,0,0,width,height,0)
    Win32API.focusWindow
    return [width,height]
  end
 
  def Win32API.restoreScreen   
    setWindowLong = Win32API.new('user32','SetWindowLong','LLL','L')
    setWindowPos  = Win32API.new('user32','SetWindowPos','LLIIIII','I')
    metrics = Win32API.new('user32','GetSystemMetrics','I','I')
    hWnd = pbFindRgssWindow
    width  = DEFAULTSCREENWIDTH*$ResizeFactor
    height = DEFAULTSCREENHEIGHT*$ResizeFactor
    if $PokemonSystem && $PokemonSystem.border==1
      width += BORDERWIDTH*2*$ResizeFactor
      height += BORDERHEIGHT*2*$ResizeFactor
    end
    x = [(metrics.call(0)-width)/2,0].max
    y = [(metrics.call(1)-height)/2,0].max
    setWindowLong.call(hWnd,-16,0x14CA0000)
    setWindowPos.call(hWnd,0,x,y,width+6,height+29,0)
    Win32API.focusWindow
    return [width,height]
  end
end



#### EDIT THESE WITH GAME VERSION
GAMEVERSION = "13"
ERRORTEXT = "Update to latest version, if error still persists please report on the bug reporting thread.\n"