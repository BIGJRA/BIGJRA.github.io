# Defines an event that procedures can subscribe to.
class Event
  def initialize
    @callbacks=[]
  end

# Sets an event handler for this event and removes all other event handlers.
  def set(method)
    @callbacks.clear
    @callbacks.push(method)
  end

# Removes an event handler procedure from the event.
  def -(method)
    for i in 0...@callbacks.length
      if @callbacks[i]==method
        @callbacks.delete_at(i)
        break
      end
    end
    return self
  end

# Adds an event handler procedure from the event.
  def +(method)
    for i in 0...@callbacks.length
      if @callbacks[i]==method
        return self
      end
    end
    @callbacks.push(method)
    return self
  end

# Clears the event of event handlers.
  def clear
    @callbacks.clear
  end

# Triggers the event and calls all its event handlers.  Normally called only
# by the code where the event occurred.
# The first argument is the sender of the event, the second argument contains
# the event's parameters. If three or more arguments are given, this method
# supports the following callbacks:
# proc {|sender,params| } where params is an array of the other parameters, and
# proc {|sender,arg0,arg1,...| }
  def trigger(*arg)
    arglist=arg[1,arg.length]
    for callback in @callbacks
      if callback.arity>2 && arg.length==callback.arity
        # Retrofitted for callbacks that take three or more arguments
        callback.call(*arg)
      else
        callback.call(arg[0],arglist)
      end
    end
  end
 
# Triggers the event and calls all its event handlers.  Normally called only
# by the code where the event occurred. The first argument is the sender of the
# event, the other arguments are the event's parameters.
  def trigger2(*arg)
    for callback in @callbacks
      callback.call(*arg)
    end
  end
end



class HandlerHash
  def initialize(mod)
    @mod=mod
    @hash={}
    @addIfs=[]
    @symbolCache={}
  end

  def fromSymbol(sym)
    if sym.is_a?(Symbol) || sym.is_a?(String)
      mod=Object.const_get(@mod) rescue nil
      return nil if !mod
      return mod.const_get(sym.to_sym) rescue nil
    else
      return sym
    end
  end

  def toSymbol(sym)
    if sym.is_a?(Symbol) || sym.is_a?(String)
      return sym.to_sym
    else
      ret=@symbolCache[sym]
      return ret if ret
      mod=Object.const_get(@mod) rescue nil
      return nil if !mod
      for key in mod.constants
        if mod.const_get(key)==sym
          ret=key.to_sym
          @symbolCache[sym]=ret
          break
        end
      end
      return ret
    end
  end

  def addIf(condProc,handler)
    @addIfs.push([condProc,handler])
  end

  def add(sym,handler) # 'sym' can be an ID or symbol
    id=fromSymbol(sym)
    @hash[id]=handler if id
    symbol=toSymbol(sym)
    @hash[symbol]=handler if symbol
  end

  def copy(src,*dests)
    handler=self[src]
    if handler
      for dest in dests
        self.add(dest,handler)
      end
    end
  end

  def [](sym) # 'sym' can be an ID or symbol
    id=fromSymbol(sym)
    ret=nil
    if id && @hash[id] # Real ID from the item
      ret=@hash[id]
    end
    symbol=toSymbol(sym)
    if symbol && @hash[symbol] # Symbol or string
      ret=@hash[symbol]
    end
    if !ret
      for addif in @addIfs
        if addif[0].call(id)
          return addif[1]
        end
      end
    end
    return ret
  end

  def trigger(sym,*args)
    handler=self[sym]
    return handler ? handler.call(fromSymbol(sym),*args) : nil
  end

  def clear
    @hash.clear
  end
end