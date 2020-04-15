property searchKeyList : {"kyle", "escarpment","buda","manchaca","William Cannon"}
property slot_site_url : "https://www.heb.com"
property phone_num : "123456789"
property freeOnlySlots : false

global current_store
global window_avail
global daydate
global dayofweek
global found_slot


on checkDisabledbyClass(theClassName, elementnum, tab_num, window_id)
	tell application "Safari"
		return do JavaScript "document.getElementsByClassName('" & theClassName & "')[" & elementnum & "].disabled;" in tab tab_num of window id window_id
	end tell
end checkDisabledbyClass

-- on checkDisplaybyClass(theClassName, elementnum, tab_num, window_id)
-- 	tell application "Safari"
-- 		return do JavaScript "document.getElementsByClassName('" & theClassName & "')[" & elementnum & "].style.display;" in tab tab_num of window id window_id
-- 	end tell
-- end checkDisplaybyClass

on checkIDExist(theID, tab_num,window_id)
	tell application "Safari"
		set exist to do JavaScript "var x = document.getElementById('" & theID & "');(x!=null);" in tab tab_num of window id window_id
	end tell
	return exist 
end checkIDExist

on checkDisplaybyClass(theClassName, elementnum, tab_num, window_id)
	tell application "Safari"
		return do JavaScript "var x = document.getElementsByClassName('" & theClassName & "')[" & elementnum & "];
		                       window.getComputedStyle(x).display" in tab tab_num of window id window_id
	end tell
end checkDisplaybyClass

on checkDisplaybyId(theID, tab_num, window_id)
	tell application "Safari"
		return do JavaScript "var x = document.getElementById('" & theID & "');
		                       window.getComputedStyle(x).display" in tab tab_num of window id window_id
	end tell
end checkDisplaybyId

on clickDivClassName(divId, buttonClassName, elementnum, tab_num, window_id)
	tell application "Safari"
		do JavaScript "var x = document.getElementById('" & divId & "'); 
		         x.getElementsByClassName('" & buttonClassName & "')[" & elementnum & "].click();" in tab tab_num of window id window_id
		delay 0.5
	end tell
end clickDivClassName

on checkClassLen(theClassName, tab_num, window_id)
	tell application "Safari"
		return do JavaScript "document.getElementsByClassName('" & theClassName & "').length;" in tab tab_num of window id window_id
	end tell
end checkClassLen


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

on toCurbsidePage(heb_win_id)
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
	set theResponse to display dialog "Enter Phone number: " default answer phone_num with icon note buttons {"Cancel", "Continue"} default button "Continue" with title "Recipient Phone Number"
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
	set phone_num to phoneNumber
end getPhoneNumber

on getKeywordsList()
	set dialogString to "Add closest keywords of your intended store names such that the store will appear as the first item in search results.
	 You can try the keywords on heb.com first. 
	 The script will only select the first store from each keyword entered.
	 Use comma ',' to seperate each keyword.  
	e.g:  Olmos,Kyle,san marcos" 
	set Applescript's text item delimiters to ","
	set searchKeyString to searchKeyList as string
	set theResponse to display dialog dialogString default answer searchKeyString with icon note buttons {"Cancel", "Continue"} default button "Continue" with title "Store keywords"
		if button returned of theResponse = "Continue" then
			set textreturned to text returned of theResponse
			try 
				set searchKeyList to every text item of textreturned
			on error errMsg number errNum
				log errNum
				log errMsg
			end try
	set Applescript's text item delimiters to ","
	log (searchKeyList as string)
end if 
end getKeywordsList

on getFreeOrAny()
	set dialogString to "Choose to search only for free slots or any slots (Free or with fee. HEB releases some slots for a $4.95 fee with closer date)"
	display dialog dialogString buttons {"Cancel", "Free Only Slots", "Any Slots"} default button "Any Slots" with title "Free or Any" with icon note
	if result = {button returned:"Free Only Slots"} then
		set freeOnlySlots to true
	else if result = {button returned:"Any Slots"} then
		set freeOnlySlots to false
	end if
end getFreeOrAny


on checkReviewChanges(tab_num, window_id)
	set deletedItems to {}
	if checkDisplaybyId("cart-change-warning-modal", tab_num,window_id) is not "none" then 
		tell application "Safari"
			set cartUnavailCount to do JavaScript "document.getElementsByClassName(\"cart-table__row--is-removing\").length;" in tab tab_num of window id window_id
			repeat with itemIterator from 0 to cartUnavailCount - 1	
				set end of deletedItems to (do JavaScript "document.getElementsByClassName(\"cart-table__name\")[" & itemIterator & "].textContent;" in tab tab_num of window id window_id)
			end repeat
			my clickDivClassName("cart-change-warning-modal___BV_modal_footer_", "btn-primary", 0, tab_num, window_id)
			delay 3
		end tell
	end if
	set Applescript's text item delimiters to ","
	log "Following items will be deleted from cart: " & (deletedItems as string)
	return deletedItems
end checkReviewChanges

on findSelectedIdx(tab_num,window_id)
	tell application "Safari"
		return do JavaScript "var day_array = document.getElementsByClassName(\"picker-day__button\");
							 var returnIdx = 0; 
							 for (var i = 0; i< day_array.length; i++){
								 if (day_array[i].classList.contains(\"picker-day__button--selected\")) {
									returnIdx = i;
									break; 
								 }
							 }
							 returnIdx; " in tab tab_num of window id window_id
	end tell
end findSelectedIdx

on findNextFreeDay(tab_num, window_id)
	set foundDay to false
	set currentIdx to findSelectedIdx(tab_num, window_id)
	repeat 
		repeat with idx from currentIdx+1 to 4   -- 5 days in one screen 
			set slotFull to checkDisplaybyClass("picker-day__no-slots-available", idx, tab_num, window_id)
			set free to checkDisplaybyClass("picker-day__fee", idx, tab_num, window_id)
			if (slotFull = "none") and (free is not "none") then
				clickClassName("picker-day__button", idx, tab_num, window_id)
				delay 1
				return idx
			end if 
		end repeat
		if checkDisabledbyClass("picker-day__scroll--next", 0, tab_num,window_id) then
			exit repeat
		end if 
		clickClassName("picker-day__scroll--next", 0, tab_num, window_id)
		delay 1
		set currentIdx to -1
	end repeat
	return -1
end findNextFreeDay


script main
	set found_slot to false
	set heb_win_id to false
	getKeywordsList()
	getPhoneNumber()
	getFreeOrAny()
	set freeString to ""
	repeat until found_slot
		set heb_win_id to toCurbsidePage(heb_win_id)
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
			-- log checkDisabledbyClass("picker-day__scroll--prev", 0,-1,heb_win_id)
			-- log checkDisabledbyClass("picker-day__scroll--next", 0,-1,heb_win_id)
			-- log checkClassLen("picker-day__button",-1,heb_win_id )
			-- log checkDisplaybyClass("picker-day__no-slots-available", 3,-1,heb_win_id )
			-- log checkDisplaybyClass("picker-day__no-slots-available", 0,-1,heb_win_id )

			set deletedItems to checkReviewChanges(-1, heb_win_id)

			tell application "Safari"
				set current_store to do JavaScript "addr_pickerbox = document.getElementsByClassName(\"address-picker\")[0]; addr_pickerbox.getElementsByClassName(\"store-card__name\")[0].textContent;" in tab -1 of window id heb_win_id
				set window_avail to do JavaScript "section = document.getElementsByClassName(\"timeslot-modal-form-body\")[0]; section.getElementsByClassName(\"picker-time\").length;" in tab -1 of window id heb_win_id
				if window_avail >= 1 then
					if freeOnlySlots then 
						set freeString to "free "
						set is_current_slot_free to do JavaScript "document.getElementsByClassName(\"picker-time__fee-amount\")[0].textContent.toLowerCase()== 'free';" in tab -1 of window id heb_win_id
						if not is_current_slot_free then 
							log "current selected day is not free"
							set dayIdx to my findNextFreeDay(-1, heb_win_id)
							log "day " & dayIdx & " is free"
							set window_avail to do JavaScript "section = document.getElementsByClassName(\"timeslot-modal-form-body\")[0]; section.getElementsByClassName(\"picker-time\").length;" in tab -1 of window id heb_win_id
						end if 
					end if 
					-- Get the current selected date info
					set daydate to do JavaScript "section = document.getElementsByClassName(\"timeslot-modal-form-body\")[0]; 
					                              section = section.getElementsByClassName(\"day-selected\")[0]; 
												  section.getElementsByClassName('picker-day__date')[0].textContent.trim();" in tab -1 of window id heb_win_id
					set dayofweek to do JavaScript "section = document.getElementsByClassName(\"timeslot-modal-form-body\")[0]; 
					                               section = section.getElementsByClassName(\"day-selected\")[0]; 
												section.getElementsByClassName('picker-day__of-week')[0].textContent.trim();" in tab -1 of window id heb_win_id
				end if
			end tell
			log current_store
			-- log window_avail
			-- log window_avail >= 1
			if window_avail >= 1 then
				log daydate
				log dayofweek
				set txtBody to "Found curbside " & freeString & " slot at store " & current_store & " on " & daydate & " " & dayofweek
				sendMessages(phone_num, txtBody)
				log "message sent for " & txtBody
				say "Curbside " & freeString & "slot found at store " & current_store & " on " & daydate & " " & dayofweek
				set found_slot to true
			end if
			delay 2
		end repeat
		-- set found_slot to true
		if not found_slot then
			set wait_time to 180
			log "wait for " & wait_time & "s"
			delay wait_time
		end if
	end repeat
	--	tell application "Safari"
	--		set miniaturized of window id heb_win_id to false
	--	end tell
	log "END"
end script

run main
