variable "db_tier" {
  type = map(string)
  default = {
    devka    = "Basic"    
    qa2      = "S0"    
    demo2    = "S1"
    eupr001ent  = "S1"
  }
}

variable "database_edition" {
  type = map(string)
  default = {
    devka       = "Basic"
    qa2         = "Standard"
    demo2       = "Standard" 
    eupr001ent  = "Standard"     
  }
}

variable "min_rsob" {
  type = map(string)
  default = {
    devka       = "Basic"
    qa2         = "Basic"   
    demo2       = "S0" 
    eupr001ent  = "S0"  
  }
}
variable "max_rsob" {
  type = map(string)
  default = {
    devka       = "S1"
    qa2         = "S1"  
    demo2       = "S2" 
    eupr001ent  = "S2"  
  }
}


variable "upscale" {
  type = map(string)
  default = {
    devka    = "upd"    
    qa2      = "upq"    
    demo2    = "up2"
    eupr001ent  = "upp"
  }
}

variable "downscale" {
  type = map(string)
  default = {
    devka    = "dwd"    
    qa2      = "dwq"    
    demo2    = "dw2"
    eupr001ent  = "dwp"
  }
}

variable "dbdownscalethreshold" {
  type = map(string)
  default = {
    devka    = "10"    
    qa2      = "10"    
    demo2    = "10"
    eupr001ent  = "10"
  }
}

variable "dbupscalethreshold" {
  type = map(string)
  default = {
    devka    = "80"    
    qa2      = "80"    
    demo2    = "80"
    eupr001ent  = "80"
  }
}

variable "dbmindtulimit" {
  type = map(string)
  default = {
    devka    = "5"    
    qa2      = "5"    
    demo2    = "5"
    eupr001ent  = "5"
  }
}
