---
layout: post
title: Adwords Scripts 
modified: 2015-12-04T08:54:57-06:00
categories: 
excerpt: "Use AdWords Scripts & the Twilio API to keep track of when things go out of stock"
tags: [posts, Noah]
image:
  feature: l.jpg
  credit: IG
  creditlink: https://instagram.com/andnoahsaid
date: 2015-11-10T22:37:57-06:00
---

# Advertise products online and have problems when things are out of stock?

I had a problem where I was running product ads on a variety of platforms, but things would go out of stock and my application wasn't able to automatically turn ads off. I figured out a way to use Adwords Scripts & the Twilio API to notify me of these changes! 

## The problem:
I was working on a project where I was advertising products that had limited quantities that I wasn't aware of, and multiple referral sources bringing traffic to the product page. In addition, the action I was tracking to use as a conersion wasn't necessarily a purchase, pageview or outbound click. Couple that with a conversion tracking system that wans't always accurate and I had a real issue on my hands.
For the first few months of the project, I just sent traffic to the product lisitng page and waited until someone watching the page notified me that the product was no longer available. This worked out for awhile until there was a miscommunication and I ended up paying several thousand dollars to send traffic to an inactive page. 
I had been looking into AdWords Scripts for awhile to automate some AdWords work I was doing and I came across [FreeAdwordsScripts.com](http://www.freeadwordsscripts.com) and began to explore how some of the example scripts there could help. I learned how to connect a script to a Google Sheet and extract infromation, and I found the most helpful example [how to connect the Twilio API](http://www.freeadwordsscripts.com/2014/01/make-calls-and-send-text-messages-to.html) to your Scripts account, thus allowing you automate text messages reporiting anomalies with your account (or in my case, pages I was tracking).
[Here's a spreadsheet to copy](https://docs.google.com/spreadsheets/d/1wMtmhR7um578l4HWVf-PSa0e1KLoR-5u8khbxj1CVLg/edit?usp=sharing). The sheet uses the named range in the sheet to run. If you only need to track one URL


## Here's the full code:
```javascript
/***************************************
*Out of Stock Checker Script v2.3
*
*
*2.3 changes: Added Twilio capibility to send texts when there is a problem with a URL
******/

//variables needed for teh script
var spreadsheet_url = "SPREADSHEET_URL_HERE";

var TEXT_CHANGED = "Whatever you're looking to track";
var subject = "URL CHANGE!";
var recipient = "you@example.com";
var results = "There was a change at: ";
var sid = 'GET_YOUR_OWN';
var auth = 'FROM_TWILIO';
var client = new Twilio(sid,auth);

function main() {
	//put a spreadsheet range into an array
	var iter = buildSelector();
	for (var i = 0; i < iter.length; i++) {
		//iterate through the range to create urls to fetch
		var deal = iter[i];
		//get the source of an item in the array
		htmlCode = UrlFetchApp.fetch(deal).getContentText();
		//check the source for text
		if (htmlCode.indexOf(TEXT_CHANGED) >= 0) {
			//send an email if changed
			MailApp.sendEmail(recipient, subject, results+entity);
			//send a text if changed
			client.sendMessage('+14124179263','+13123136668',"This Deal Has Expired: "+deal)
        	//log the expired urls. mostly here as a debugger
        	Logger.log("this is expired: "+deal);
		} else {
			//log the good urls. mostly here as a debugger
			Logger.log(deal+" is good")
		}
	} 
}



function buildSelector () {
	var spreadsheet = SpreadsheetApp.openByUrl(spreadsheet_url);
	var sheet = spreadsheet.getRangeByName('URLS_TO_TRACK');
	var selector = new Array();
	var sheet_values = sheet.getValues();
	for (var i = 0; i < sheet_values.length; i++) {
		//if(sheet_values[i][0] == ""){
			//continue
			//var selector = sheet_values;
		//}
			var selector = sheet_values
	}
	return selector;
	//Logger.log(selector);
}

function Twilio(accountSid, authToken) {
  this.ACCOUNT_SID = accountSid;
  this.AUTH_TOKEN = authToken;
   
  this.MESSAGES_ENDPOINT = 'https://api.twilio.com/2010-04-01/Accounts/'+this.ACCOUNT_SID+'/Messages.json';
  this.CALLS_ENDPOINT = 'https://api.twilio.com/2010-04-01/Accounts/'+this.ACCOUNT_SID+'/Calls.json';
 
  this.sendMessage = function(to,from,body) {
    var httpOptions = {
      method : 'POST',
      payload : {
        To: to,
        From: from,
        Body: body
      },
      headers : getBasicAuth(this)
    };
    var resp = UrlFetchApp.fetch(this.MESSAGES_ENDPOINT, httpOptions).getContentText();
    return JSON.parse(resp)['sid'];
  }
   
  this.makeCall = function(to,from,whatToSay) {
    var url = 'http://proj.rjsavage.com/savageautomation/twilio_script/dynamicSay.php?alert='+encodeURIComponent(whatToSay);
    var httpOptions = {
      method : 'POST',
      payload : {
        To: to,
        From: from,
        Url: url
      },
      headers : getBasicAuth(this)
    };
    var resp = UrlFetchApp.fetch(this.CALLS_ENDPOINT, httpOptions).getContentText();
    return JSON.parse(resp)['sid'];
  
   
  function getBasicAuth(context) {
    return {
      'Authorization': 'Basic ' + Utilities.base64Encode(context.ACCOUNT_SID+':'+context.AUTH_TOKEN)
    };
  }
}
```