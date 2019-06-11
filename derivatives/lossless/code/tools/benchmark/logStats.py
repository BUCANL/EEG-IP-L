''' logStats.py
A small script that runs through all the log files and creates
a CSV file with data about runtime and memory usage '''

import os

if __name__=="__main__":

    # Find all log filenames
    filenames = []
    subdirs   = [x[0] for x in os.walk('analysis/log/')]
    for subdir in subdirs:
        files = os.walk(subdir).next()[2]
        if len(files) > 0:
            for f in files:
                    if os.path.splitext(f)[-1]=='.log':
                        filenames.append(os.path.join(subdir+'/'+f))

    # create dictionary to store all relevant data
    data = {}
    for f in filenames:    
        parts = f.split('/')
        script = parts[2].split('-')[0]
        if parts[3] not in data:
            data[parts[3]] = {}
            data[parts[3]][script] = {}
        else:
            data[parts[3]][script] = {}
    
    # find necessary data in log files and append to list
    for f in filenames:
        print "checking",f
        filename = os.path.basename(f)
        script   = f.split('/')[2].split('-')[0]
        logFile = open(f,'r')
        lines = logFile.readlines()
        logFile.close()
        good = False
        for line in lines: # skip file if epilogue failed to print
            if '--- MaeNET Epilogue ---' in line or \
               '--- SharcNET Job Epilogue ---' in line:
                good = True                
                break
        if not good: continue
        hasID = hasSched = False
        for line in lines:
            line = line.lstrip()
            value = ''
            if 'Scheduler:' in line:
                scheduler = line.split(': ')[-1].rstrip('\n')
                if 'scheduler' not in data[filename][script]:
                    data[filename][script]['scheduler'] = [scheduler]
                else: 
                    data[filename][script]['scheduler'].append(scheduler)
                hasSched = True
                #print ("Scheduler:",scheduler)
                continue
            # look for number of channels and samples
            # if unavailable, the number from the previous
            # file is used - this is why we sort above by data file
            if 'Number of Channels:' in line or 'data_dim =' in line:
                numChans = line.split(' ')[-1].rstrip('\n')
                data[filename]['chans'] = numChans
                #print ("# Chans:",numChans)
                continue
            if 'Number of Samples:' in line or 'field_dim =' in line:
                numSamps = line.split(' ')[-1].rstrip('\n')
                data[filename]['samps'] = numSamps
		        #print ("# Samps:",numSamps)
                continue
            if line.startswith('job id:'):
                jobID = line.split(': ')[-1].rstrip()
                if 'id' not in data[filename][script]:
                    data[filename][script]['id'] = [jobID]
                else:
                    data[filename][script]['id'].append(jobID)
		        #print ("Job ID:",line.split(': ')[1].rstrip())
                hasID = True
                continue
            if line.startswith('elapsed time:'):
                time = line.split(': ')[1].split('s /')[0]
                if 'h' in time:
                    time = str(int(float(time.split('h')[0])*3600))
                if 'time' not in data[filename][script]:
                    data[filename][script]['time'] = [time]
                else:
                    data[filename][script]['time'].append(time)
                #print ("elapsed:",time)
                continue
            if line.startswith('virtual memory:') or \
               line.startswith('resident memory:'):
                memory = line.split(': ')[1].split('M /')[0]
                if 'G' in memory:
                    memory = str(float(memory.split('G')[0])*1000)
                if 'K' in memory:
                    memory = str(float(memory.split('K')[0])/1000)
                if 'memory' not in data[filename][script]:
                    data[filename][script]['memory'] = [memory]
                else:
                    data[filename][script]['memory'].append(memory)
		        #print ('memory:',memory)
                continue
            if line.startswith('exit status:') and line.strip()[-1]!='0':
                print "\t<SKIPPED DUE TO NON-ZERO EXIT STATUS>" # if error occurred, skip this file
                if hasID:
                    data[filename][script]['id'] = data[filename][script]['id'][:-1]
                if hasSched:                
                    data[filename][script]['scheduler'] = data[filename][script]['scheduler'][:-1]
                break

    # Create CSV file and write the data to it
    outFile = open('analysis/support/tools/benchmark/benchmark.csv','w')
    outFile.write('script\tscheduler\tchans\tsamples\tjob_ID\telapsed_time\tmemory_MB\n')
    for filename,scripts in data.iteritems():
        for script, vals in scripts.iteritems():
            #print filename, script, vals
            if script=='chans' or script=='samps' or not vals:
                continue
            for i in range(0,len(vals['id'])):
                if 'time' not in vals or len(vals['time']) <= i:
                    time = 'NA'
                else:
                    time = vals['time'][i]
                if 'memory' not in vals or len(vals['memory']) <= i:
                    memory = 'NA'
                else:
                    memory = vals['memory'][i]
                outFile.write('\t'.join([script,vals['scheduler'][i],scripts['chans'],
                                        scripts['samps'],vals['id'][i],time,memory])+'\n')
    print "\n--- DONE: logStats ---\n"
