#Set industry
industry = "News"

setIndustry = (industry) ->
  $('span.industry').html(industry)


#Make times better looking
prettyPlaceTimes = (times) ->
  times = ((numeral(time/60).format('0,0.0')) + " minutes" for time in times)
  $('#avgtime').html(times[0])
  $('#mediantime').html(times[1])
  $('#alltime').html(times[2])
  $('#industrytime').html(times[3])
  return


#change arrow direction
changeArrow = (change, id) ->
  thing = "." + id
  if change > 0
    $(thing).addClass("positive")
  else if change < 0 
    $(thing).addClass("negative")

#Cleans update values with commas, decimal points
makePrettyBig = (ugly) ->
  for k of ugly
    ugly[k] = numeral(ugly[k]).format('0,0')
  placePretty(ugly)
  

#place big numbers
placePretty = (pretty) ->
  for k of pretty
    $('#'+k).html(pretty[k])
  

makePrettyPercent = (ugly) ->
  for k of ugly
    ugly[k] = numeral(ugly[k]).format('0,0.0')
  placePretty(ugly)
  

#This cleans the benchmark percentages
makeBenchmarkPretty = (ugly) ->
  for k of ugly["All"]
    string = ugly["All"][k]["growth"] * 100  
    ugly["All"][k]["growth"] = numeral(string).format('0,0.0')
  for k of ugly["News"]
    string = ugly["News"][k]["growth"] * 100  
    ugly["News"][k]["growth"] = numeral(string).format('0,0.0')
  placeBench(ugly)
  string

#Put the benchmark values in the Dom
placeBench = (pretty) ->
  for k of pretty['All']
    benchId = "#all_" + k
    $(benchId).text(pretty["All"][k]["growth"])
  for k of pretty["News"]
    benchId = "#industry_" + k
    $(benchId).text(pretty["News"][k]["growth"])
  return

#This calculates the percentages used
getPercentChange = (thing) ->
  percentChangeSessions = ((thing[0]['sessions'] - thing[1]['sessions'])/thing[1]['sessions'])*100
  percentChangeUsers = ((thing[0]['users'] - thing[1]['users'])/thing[1]['users'])*100
  percChange = { userchange: percentChangeUsers, sessionchange: percentChangeSessions}
  thing.push percChange
  makePrettyPercent(thing[2])
  for k of percChange
    changeArrow(percChange[k], k)
  percentChangeSessions

#Adds json objects to an array to be processed
updateUS = ->
  $.ajax
    cache: false
    success: (data) ->
      us = []
      us[0] = data.values.recent
      us[1] = data.values.past
      newUs = []
      newLocs = {}
      otherLocs = {}
      times = {}
      newTimes = []
      bench = []
      bench = data.benchmarks
      newBench = []
      newBenches = {}
      otherBenches = {}

      for k,v of bench['All']
        newBenches[k] = v
      newBench.push newBenches
      for k,v of bench['News']
        otherBenches[k] = v if k
      newBench.push otherBenches


      newTimes.push us[0]['median session']
      newTimes.push us[0]['avg session']
      newTimes.push bench['All']["avg_session_length"]['value']
      newTimes.push bench['News']["avg_session_length"]['value']


      for k,v of us[0]
        newLocs[k] = v if k is "sessions" or k is "users"
      newUs.push newLocs
      for k,v of us[1]
        otherLocs[k] = v if k is "sessions" or k is "users"
      newUs.push otherLocs

      makeBenchmarkPretty(bench)
      setIndustry(industry)
      prettyPlaceTimes(newTimes)
      getPercentChange(newUs)
      makePrettyBig(newUs[0])
      return
    url: 'js/data.json'
  return



