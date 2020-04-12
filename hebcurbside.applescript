property searchKeyList : {"kyle", "victoria"}
property slot_site_url : "https://www.heb.com"


global phone_num
global current_store
global window_avail
global daydate
global dayofweek


on clickClassName(theClassName, elementnum, tab_num, window_id)
	tell application "Safari"
		do JavaScript "document.getElementsByClassName('" & theClassName & "')[" & elementnum & "].click();" in tab tab_num of window id window_id
		delay 0.5
	end tell
end clickClassName

on clickID(theID, tab_num, window_id)
	tell application "Safari"
		do JavaScript "document.getElementById('" & theID & "').click();" in tab tab_num of window id window_id
		delay 0.5
	end tell
end clickID

on setValueByID(theID, value, tab_num, window_id)
	tell application "Safari"
		do JavaScript "document.getElementById('" & theID & "').value='" & value & "';" in tab tab_num of window id window_id
		delay 0.5
	end tell
end setValueByID

on sendMessages(phoneNumber, msgBody)
	-- Credit for texting code: Sean Pinkey, https://github.com/spinkney
	tell application "Messages"
		set targetService to 1st service whose service type = iMessage
		set targetBuddy to buddy phoneNumber of targetService
		send msgBody to targetBuddy
	end tell
	log "text message sent about slot found"
end sendMessages

on toCurbside(heb_win_id)
	tell application "Safari"
		if exists (window id heb_win_id) then
			log "reload page"
			set URL of tab -1 of window id heb_win_id to slot_site_url
		else
			make new document with properties {URL:slot_site_url}
			delay 0.5 -- wait for new window to open
			set heb_win_id to id of front window
		end if
		--set miniaturized of window id heb_win_id to true   ... somehow this affects the page to give false information 
		
		delay 5
	end tell
	clickClassName("details curbside-icon", 0, -1, heb_win_id)
	clickID("__BVID__12___BV_tab_button__", -1, heb_win_id)
	return heb_win_id
end toCurbside

on getPhoneNumber()
	set theResponse to display dialog "Enter Phone number: " default answer "" with icon note buttons {"Cancel", "Continue"} default button "Continue" with title "Recipient Phone Number"
	if button returned of theResponse = "Continue" then
		set temp to text returned of theResponse
		-- checks if proper format entered
		if the length of temp = 10 then
			set phoneNumber to temp
			log "valid phone number entered"
		else
			display dialog invalidNumberMsg with title "Invalid Number" with icon caution
			log "invalid phone number entered"
			-- user will be reprompted for number
		end if
	end if
	return phoneNumber
end getPhoneNumber


script main
	set found_slot to false
	set heb_win_id to false
	set phone_num to getPhoneNumber()
	repeat until found_slot
		set heb_win_id to toCurbside(heb_win_id)
		repeat with keyword in searchKeyList
			set current_store to ""
			set window_avail to 0
			set daydate to ""
			set dayofweek to ""
			clickClassName("change-store-button", 0, -1, heb_win_id)
			setValueByID("change-store-input", keyword, -1, heb_win_id)
			clickClassName("search__submit", 0, -1, heb_win_id)
			delay 3
			clickClassName("store__select-button", 0, -1, heb_win_id)
			delay 3
			tell application "Safari"
				set current_store to do JavaScript "addr_pickerbox = document.getElementsByClassName(\"address-picker\")[0]; addr_pickerbox.getElementsByClassName(\"store-card__name\")[0].textContent;" in tab -1 of window id heb_win_id
				set window_avail to do JavaScript "section = document.getElementsByClassName(\"timeslot-modal-form-body\")[0]; section.getElementsByClassName(\"picker-time\").length;" in tab -1 of window id heb_win_id
				if window_avail ≥ 1 then
					--set daydate to do JavaScript "try{section = document.getElementsByClassName(\"timeslot-modal-form-body\")[0]; section = section.getElementsByClassName(\"day-selected\")[0]; return_var= section.getElementsByClassName(\"picker-day__date\")[0].textContent.trim();}catch(err){return_var=err}return_var" in tab -1 of window id heb_win_id
					--set dayofweek to do JavaScript "try{section = document.getEleentsByClassName(\"timeslot-modal-form-body\")[0]; section = section.getElementsByClassName(\"day-selected\")[0]; return_var=section.getElementsByClassName(\"picker-day__of-week\")[0].textContent.trim();}catch(err){return_var=err}return_var" in tab -1 of window id heb_win_id
					set daydate to do JavaScript "section = document.getElementsByClassName(\"timeslot-modal-form-body\")[0]; section = section.getElementsByClassName(\"day-selected\")[0]; section.getElementsByClassName('picker-day__date')[0].textContent.trim();" in tab -1 of window id heb_win_id
					set dayofweek to do JavaScript "section = document.getElementsByClassName(\"timeslot-modal-form-body\")[0]; section = section.getElementsByClassName(\"day-selected\")[0]; section.getElementsByClassName('picker-day__of-week')[0].textContent.trim();" in tab -1 of window id heb_win_id
					delay 0.5
				end if
			end tell
			log current_store
			log window_avail
			log window_avail ≥ 1
			if window_avail ≥ 1 then
				log daydate
				log dayofweek
				set txtBody to "Found slot at store " & current_store & " on " & daydate & " " & dayofweek
				sendMessages(phone_num, txtBody)
				log "message sent for " & txtBody
				say "Curbside slot found at store " & current_store & " on " & daydate & " " & dayofweek
				set found_slot to true
				
			end if
			delay 2
		end repeat
		if not found_slot then
			delay 60
		end if
	end repeat
	--	tell application "Safari"
	--		set miniaturized of window id heb_win_id to false
	--	end tell
	log "END"
end script

run main
