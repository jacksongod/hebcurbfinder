# hebcurbfinder
A Mac only Apple script to help find HEB Curbside slot. [H-E-B](https://www.heb.com) is an American privately held supermarket chain based in San Antonio, Texas. 

## Feature 
Given one or more keywords for intended HEB stores and phone number , the script will find the next avaible slots(free or not) from heb.com and notify user by sending voice notification and messages to given phone number. 

## Requirements 
- MacOS system.
- Messages app is set up for sending messages 
- User provides a list search keywords for intended HEB store locations , and phone number for receving message/imessage. 

## Instructions
1. The script only works for HEB Curbside pick up so far, not support for delivery slot(yet)
2. Download 'hebcurbside.scpt' [here](https://github.com/jacksongod/hebcurbfinder/raw/master/hebcurbside.scpt) or git clone.
3. Enable "Allow JavaScript from Apple Events". [How-to video](https://www.youtube.com/watch?v=S6zb_6yTAbo)
4. (optional) open Safari and log into your HEB account 
5. Open hebcurbside.scpt in _Script Editor_ and Hit run button and follow prompts to enter Store search keywords and phone number.

6. Turn up the volume to hear the notification when a slot is found, or a message will be sent to the phone number provided. Once curbside slot found, you will need to reserve the slot yourself, and checkout with in 1 hour(as of now). No auto-reservation provided from script for avoiding potential abuse.

7. Script will stop once any slots(either free or with fee) are found from any of the store(s) searched


Notes:
The script will stop running if your computer falls asleep. You can adjust your 'Energy Saver' settings in System Preferences or download [Caffeine app](https://intelliscapesolutions.com/apps/caffeine) to keep your Mac awake.



#Credits
Project is inspired by [Amazon-Fresh-Whole-Foods-delivery-slot-finder](https://github.com/ahertel/Amazon-Fresh-Whole-Foods-delivery-slot-finder) 
Part of the code , flow and instructions are directly from it. 