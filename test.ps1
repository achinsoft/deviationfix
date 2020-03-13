$str=Get-Content .\test.txt
foreach($line in $str){
    for($i=0;$i -lt $line.Length;$i++){
        if(-not($line[$line.IndexOf('"')+2] -eq ":")){
            $st=$line.IndexOf('"')+2
            $line=$line.Substring($st)
            $line
        }
    }
    

}

#$str.Length
#for($i=0;$i -le $str.Length;$i++){
    
        
 #   }
#}