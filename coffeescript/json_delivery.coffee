#Set industry
industry = "News"

setIndustry = (industry) ->
  $('span.industry').html(industry);


#Make times better looking
prettyPlaceTimes = (times) ->
  times = (time/60 for time in times)
  times = (numeral(time).format('0,0.0') for time in times)
  document.getElementById('avgtime').innerHTML = times[0] + " minutes"
  document.getElementById('mediantime').innerHTML = times[1] + " minutes"
  document.getElementById('alltime').innerHTML = times[2] + " minutes"
  document.getElementById('industrytime').innerHTML = times[3] + " minutes"


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
  PlacePretty(ugly)
  return ugly

#place big numbers
PlacePretty = (pretty) ->
  for k of pretty
    document.getElementById(k).innerHTML = pretty[k]
  return

makePrettyPercent = (ugly) ->
  for k of ugly
    ugly[k] = numeral(ugly[k]).format('0,0.0')
  PlacePretty(ugly)
  return

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



