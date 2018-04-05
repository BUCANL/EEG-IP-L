import os

if __name__=="__main__":

    benchmark = open('analysis/support/tools/benchmark/benchmark.out','r')

    lines = benchmark.readlines()
    benchmark.close()

    currScript = ''     # script name
    currFormula = ''    # memory or elapsed time
    currSched = ''      # scheduler

    formulas = {}
    for line in lines:
        doneCurr = False
        data = [x.rstrip('\n') for x in line.split(' ') if x != '' and x != '\n']
        if not data: continue
        if data[0].startswith("$"):
            elements = data[0][1:].split('.')
            currSched = elements[0]
            currScript = elements[1]
            if currSched not in formulas:
                formulas[currSched] = {}
            if currScript not in formulas[currSched]:
                formulas[currSched][currScript] = {}
            continue
        if data[0]=='lm(formula':
            currFormula = data[2][2:]
            continue
        if data[0]=='(Intercept)':
            if data[2]=='NA': data[2] = 0
            formula = float(data[1])+float(data[2])
            if formula < 0:  # if intercept is negative
                formula = '' # make it zero
            formula = str(formula).lstrip('0')
            continue
        if data[0]=='j$chans':
	        if data[1]=='NA': 
		        formula+='' # if data is NA, chans cannot be used in formula
		        continue
	        if formula!='': formula += '+'
                formula+=str(float(data[1].lstrip('0'))+float(data[2].lstrip('0')))+'*c'
                continue
        if data[0]=='j$samples':
            if data[1]=='NA':
                formula+='' # if data is NA, samps cannot be used in formula
            else:
                formula+='+'+str(float(data[1].lstrip('0'))/60+float(data[2].lstrip('0'))/60)+'*s'
            doneCurr = True
        if doneCurr:
            if currFormula=='memory_MB': formula+='M'
            else: formula+='m'
            formulas[currSched][currScript][currFormula] = formula
 
    cfgPath = 'analysis/support/config/'
    for scheduler,scripts in formulas.iteritems():
        templates = os.listdir(os.path.join(cfgPath,'remote-'+scheduler+'-template'))
        if not os.path.exists(os.path.join(cfgPath,'generated-'+scheduler)):
            os.makedirs(os.path.join(cfgPath,'generated-'+scheduler))
        
        for script,formula in scripts.iteritems():
            oldName = newName = 'c'+script.lstrip('s')+'_remote.cfg'
            if oldName not in templates: # if no template available for this script
                oldName = 'default.cfg'  # use default.cfg as template
                newName = script+'cfg'   # but save new cfg as script name
            
            print 'Generating ' + newName + ' for ' + scheduler + '...'
            cfgFile = open(os.path.join(cfgPath,'remote-'+scheduler+'-template',oldName), 'r')
            fileStr = cfgFile.read()
            cfgFile.close()
            newStr = fileStr.format(formula['memory_MB'],formula['elapsed_time'])
            newcfg = open(os.path.join(cfgPath,'generated-'+scheduler,newName),'w')
            newcfg.write(newStr)
            newcfg.close()

    print "\n--- DONE: generateConfig ---\n"
