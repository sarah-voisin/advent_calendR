library(shiny)
library(shinyjs)
library(googlesheets4)
library(dplyr)

# Authenticate with Google Sheets
# For deployment, you'll need to use a service account or token
gs4_auth(cache = ".secrets", email = TRUE)

# Google Sheet ID (extracted from your URL)
SHEET_ID <- "1Gk3YTtMYHfLKFCLTBr0smPnUdaYcBYBKRmIw4_DGOvM"

# Fantasy-themed quotes for each day
quotes <- list(
    "It is very hard for evil to take hold of the unconsenting soul.\n― Ursula K. Le Guin, A Wizard of Earthsea",
    "Freedom is a heavy load, a great and strange burden for the spirit to undertake. It is not easy. It is not a gift given, but a choice made, and the choice may be a hard one. The road goes upward towards the light; but the laden traveler may never reach the end of it.\n― Ursula K. LeGuin, The Tombs of Atuan",
    "No darkness lasts forever. And even there, there are stars.\n― Ursula K. Le Guin, The Farthest Shore",
    "You are beautiful, Tenar said in a different tone. Listen to me, Therru. Come here. You have scars, ugly scars, because an ugly, evil thing was done to you. People see the scars. But they see you, too, and you aren't the scars. You aren't ugly. You aren't evil. You are Therru, and beautiful. You are Therru who can work, and walk, and run, and dance, beautifully, in a red dress.\n― Ursula K. Le Guin, Tehanu",
    "It's a rare gift, to know where you need to be, before you've been to all the places you don't need to be.\n― Ursula K. Le Guin, Tales from Earthsea",
    "I’d rather get bad news from an honest man than lies from a flatterer,\n― Ursula K. Le Guin, The Other Wind",
    "Not all those who wander are lost.\n― J.R.R. Tolkien, The Fellowship of the Ring",
    "I do not love the bright sword for its sharpness, nor the arrow for its swiftness, nor the warrior for his glory. I love only that which they defend.\n― J.R.R. Tolkien, The Two Towers",
    "What do you fear, lady? [Aragorn] asked.\nA cage, [Éowyn] said. To stay behind bars, until use and old age accept them, and all chance of doing great deeds is gone beyond recall or desire.\n― J.R.R. Tolkien, The Return of the King",
    "We are all subject to the fates. But we must act as if we are not, or die of despair.\n― Philip Pullman, The Golden Compass",
    "Words are pale shadows of forgotten names. As names have power, words have power. Words can light fires in the minds of men. Words can wring tears from the hardest hearts.\n― Patrick Rothfuss, The Name of the Wind",
    "Love isn’t some scarce resource to battle over. Love can be infinite, as much as your heart can open.\n― Xiran Jay Zhao, Iron Widow",
    "Every oppressor, through their denial of humanity, sows the seed of their own destruction.\n― Xiran Jay Zhao, Heavenly Tyrant",
    "The truth. Dumbledore sighed. It is a beautiful and terrible thing, and should therefore be treated with great caution.\n― J.K. Rowling, Harry Potter and the Sorcerer's Stone",
    "It is our choices, Harry, that show what we truly are, far more than our abilities.\n― J.K. Rowling, Harry Potter and the Chamber of Secrets",
    "I solemnly swear that I am up to no good.\n― J.K. Rowling, Harry Potter and the Prisoner of Azkaban",
    "If you want to know what a man's like, take a good look at how he treats his inferiors, not his equals.\n― J.K. Rowling, Harry Potter and the Goblet of Fire",
    "Wit beyond measure is man’s greatest treasure.\n― J.K. Rowling, Harry Potter and the Order of the Phoenix",
    "The thing about growing up with Fred and George,said Ginny thoughtfully, is that you sort of start thinking anything's possible if you've got enough nerve.\n― J. K. Rowling, Harry Potter and the Half-Blood Prince",
    "Do not pity the dead, Harry. Pity the living, and, above all those who live without love.\n― J.K. Rowling, Harry Potter and the Deathly Hallows",
    "Don't feel bad for one moment about doing what brings you joy.\n― Sarah J. Maas, A Court of Thorns and Roses",
    "I'm not really sure why. But... do you stop loving someone just because they betray you? I don't think so. That's what makes the betrayal hurt so much - pain, frustration, anger... and I still loved her. I still do.\n― Brandon Sanderson, Mistborn: The Final Empire",
    "Nothing burns in your heart like the emptiness of losing something, someone, before you truly have learned of its value.\n― R.A. Salvatore, Homeland",
    "Joy multiplies when it is shared among friends, but grief diminishes with every division. That is life.\n― R.A. Salvatore, Exile"
)

# *** TEST MODE PARAMETER - SET TO TRUE TO UNLOCK ALL DAYS ***
TEST_MODE <- TRUE  # Change to TRUE to test opening all days

# *** BACKGROUND IMAGES FOR EACH DAY ***
# Replace these URLs with your GitHub image URLs
# Format: "https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/day1.jpg"
GITHUB_BASE_URL <- "https://raw.githubusercontent.com/sarah-voisin/advent_calendR/main/"

background_images <- list(
    '1' = paste0(GITHUB_BASE_URL, "ES1.jpg"),
    '2' = paste0(GITHUB_BASE_URL, "ES2.jpg"),
    '3' = paste0(GITHUB_BASE_URL, "ES3.jpg"),
    '4' = paste0(GITHUB_BASE_URL, "ES4.jpg"),
    '5' = paste0(GITHUB_BASE_URL, "ES5.jpg"),
    '6' = paste0(GITHUB_BASE_URL, "ES6.jpg"),
    '7' = paste0(GITHUB_BASE_URL, "LOTR1.jpg"),
    '8' = paste0(GITHUB_BASE_URL, "LOTR2.jpg"),
    '9' = paste0(GITHUB_BASE_URL, "LOTR3.jpg"),
    '10' = paste0(GITHUB_BASE_URL, "GC.jpg"),
    '11' = paste0(GITHUB_BASE_URL, "NW.jpg"),
    '12' = paste0(GITHUB_BASE_URL, "IW.jpg"),
    '13' = paste0(GITHUB_BASE_URL, "HT.jpg"),
    '14' = paste0(GITHUB_BASE_URL, "HP1.jpg"),
    '15' = paste0(GITHUB_BASE_URL, "HP2.jpg"),
    '16' = paste0(GITHUB_BASE_URL, "HP3.jpg"),
    '17' = paste0(GITHUB_BASE_URL, "HP4.jpg"),
    '18' = paste0(GITHUB_BASE_URL, "HP5.jpg"),
    '19' = paste0(GITHUB_BASE_URL, "HP6.jpg"),
    '20' = paste0(GITHUB_BASE_URL, "HP7.jpg"),
    '21' = paste0(GITHUB_BASE_URL, "CTR.jpg"),
    '22' = paste0(GITHUB_BASE_URL, "MFE.jpg"),
    '23' = paste0(GITHUB_BASE_URL, "HP1.jpg"),
    '24' = paste0(GITHUB_BASE_URL, "HP1.jpg")
)

# Shuffled day order for visual interest
day_order <- c(15, 3, 22, 8, 19, 1, 12, 24, 6, 17, 4, 21, 
               9, 14, 2, 20, 7, 23, 11, 16, 5, 18, 10, 13)

# Define sizes for collage effect
day_sizes <- list(
    '1' = c(1, 1), '2' = c(1, 1), '3' = c(2, 1), '4' = c(1, 1),
    '5' = c(1, 2), '6' = c(1, 1), '7' = c(1, 1), '8' = c(2, 2),
    '9' = c(1, 1), '10' = c(1, 1), '11' = c(1, 1), '12' = c(1, 2),
    '13' = c(2, 1), '14' = c(1, 1), '15' = c(1, 1), '16' = c(1, 1),
    '17' = c(2, 1), '18' = c(1, 1), '19' = c(1, 1), '20' = c(1, 1),
    '21' = c(1, 2), '22' = c(1, 1), '23' = c(1, 1), '24' = c(2, 2)
)

# Helper functions for Google Sheets
load_user_progress <- function(user_name) {
    tryCatch({
        data <- read_sheet(SHEET_ID)
        if (nrow(data) == 0) return(numeric(0))
        
        user_data <- data %>% 
            filter(tolower(Name) == tolower(user_name))
        
        if (nrow(user_data) > 0) {
            return(unique(user_data$Day))
        } else {
            return(numeric(0))
        }
    }, error = function(e) {
        message("Error loading user progress: ", e$message)
        return(numeric(0))
    })
}

save_day_opened <- function(user_name, day) {
    tryCatch({
        new_row <- data.frame(
            Name = user_name,
            Day = day,
            Opened_Date = as.character(Sys.time()),
            stringsAsFactors = FALSE
        )
        sheet_append(SHEET_ID, new_row)
        return(TRUE)
    }, error = function(e) {
        message("Error saving to sheet: ", e$message)
        return(FALSE)
    })
}

ui <- fluidPage(
    useShinyjs(),
    tags$head(
        tags$style(HTML("
      body {
        background: linear-gradient(135deg, #1e3a5f 0%, #2d1b4e 100%);
        font-family: 'Georgia', serif;
        min-height: 100vh;
      }
      .title {
        text-align: center;
        color: #ffd700;
        text-shadow: 2px 2px 4px rgba(0,0,0,0.5);
        font-size: 2.5em;
        margin: 30px 0;
        font-weight: bold;
      }
      .welcome-screen {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: linear-gradient(135deg, #1e3a5f 0%, #2d1b4e 100%);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 2000;
      }
      .welcome-box {
        background: linear-gradient(135deg, #4a3573 0%, #2d1b4e 100%);
        border: 3px solid #ffd700;
        border-radius: 20px;
        padding: 50px;
        max-width: 500px;
        text-align: center;
        box-shadow: 0 10px 50px rgba(0,0,0,0.5);
      }
      .welcome-title {
        color: #ffd700;
        font-size: 2em;
        margin-bottom: 20px;
        text-shadow: 2px 2px 4px rgba(0,0,0,0.5);
      }
      .welcome-text {
        color: #e6d5b8;
        font-size: 1.1em;
        margin-bottom: 30px;
        line-height: 1.6;
      }
      .name-input {
        width: 100%;
        padding: 15px;
        font-size: 1.1em;
        border: 2px solid #ffd700;
        border-radius: 10px;
        background: rgba(255,255,255,0.9);
        margin-bottom: 20px;
        font-family: 'Georgia', serif;
      }
      .enter-btn {
        background: #ffd700;
        color: #2d1b4e;
        border: none;
        padding: 15px 40px;
        border-radius: 25px;
        font-size: 1.2em;
        cursor: pointer;
        font-weight: bold;
        transition: all 0.3s;
        font-family: 'Georgia', serif;
      }
      .enter-btn:hover {
        background: #ffed4e;
        transform: scale(1.05);
      }
      .enter-btn:disabled {
        background: #999;
        cursor: not-allowed;
        transform: none;
      }
      .calendar-grid {
        display: grid;
        grid-template-columns: repeat(8, 1fr);
        grid-auto-rows: 100px;
        gap: 12px;
        max-width: 1100px;
        margin: 0 auto;
        padding: 20px;
      }
      .day-box {
        border: 3px solid #8b7355;
        border-radius: 15px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.5em;
        font-weight: bold;
        cursor: pointer;
        transition: all 0.3s;
        position: relative;
        overflow: hidden;
      }
      .day-box::before {
        content: '';
        position: absolute;
        top: -50%;
        left: -50%;
        width: 200%;
        height: 200%;
        background: linear-gradient(45deg, transparent, rgba(255,255,255,0.1), transparent);
        transform: rotate(45deg);
      }
      .size-1-1 { grid-column: span 1; grid-row: span 1; }
      .size-2-1 { grid-column: span 2; grid-row: span 1; }
      .size-1-2 { grid-column: span 1; grid-row: span 2; }
      .size-2-2 { grid-column: span 2; grid-row: span 2; font-size: 2em; }
      
      .unlocked {
        background: linear-gradient(135deg, #6a4c93 0%, #4a3573 100%);
        color: #ffd700;
        box-shadow: 0 4px 15px rgba(138, 43, 226, 0.4);
      }
      .unlocked:hover {
        transform: translateY(-5px);
        box-shadow: 0 8px 25px rgba(138, 43, 226, 0.6);
      }
      .locked {
        background: linear-gradient(135deg, #2c3e50 0%, #1a252f 100%);
        color: #666;
        cursor: not-allowed;
      }
      .opened {
        background: linear-gradient(135deg, #d4af37 0%, #aa8c2a 100%);
        color: #2c1810;
        box-shadow: 0 4px 15px rgba(212, 175, 55, 0.4);
      }
.quote-modal {
    position: fixed;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    border: 3px solid #ffd700;
    border-radius: 20px;
    padding: 40px;
    width: 600px;
    height: 600px;
    box-shadow: 0 10px 50px rgba(0,0,0,0.8);
    z-index: 1000;
    color: #ffd700;
    background-size: cover;
    background-position: center;
    background-repeat: no-repeat;
    overflow-y: auto;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
}
      .quote-modal::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(0, 0, 0, 0.4);
        border-radius: 17px;
        z-index: -1;
      }
      .modal-title {
        text-align: center;
        margin-top: 0;
        text-shadow: 2px 2px 4px rgba(0,0,0,0.8);
        background: rgba(45, 27, 78, 0.7);
        padding: 10px;
        border-radius: 10px;
      }
 .quote-content {
    font-size: 1.2em;
    line-height: 1.8;
    text-align: left;
    white-space: pre-line;
    text-shadow: 2px 2px 4px rgba(0,0,0,0.8);
    background: rgba(45, 27, 78, 0.7);
    padding: 20px;
    border-radius: 10px;
    display: inline-block;
    max-width: 90%;
}
      .close-btn {
        background: #ffd700;
        color: #2d1b4e;
        border: none;
        padding: 10px 30px;
        border-radius: 25px;
        font-size: 1em;
        cursor: pointer;
        font-weight: bold;
        transition: all 0.3s;
      }
      .close-btn:hover {
        background: #ffed4e;
        transform: scale(1.05);
      }
      .modal-overlay {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(0,0,0,0.7);
        z-index: 999;
      }
      .day-number {
        font-size: 1em;
        z-index: 1;
      }
      .size-2-2 .day-number {
        font-size: 1.3em;
      }
      .test-mode-banner {
        background: #ff6b6b;
        color: white;
        text-align: center;
        padding: 10px;
        font-weight: bold;
        font-size: 1.1em;
      }
      .user-greeting {
        text-align: center;
        color: #e6d5b8;
        font-size: 1.1em;
        margin-top: -20px;
        margin-bottom: 10px;
      }
      .loading-text {
        color: #e6d5b8;
        font-size: 0.9em;
        margin-top: 10px;
      }
    "))
    ),
    
    # Welcome screen
    div(id = "welcome_screen", class = "welcome-screen",
        div(class = "welcome-box",
            div(class = "welcome-title", "✨ Welcome, Traveler! ✨"),
            div(class = "welcome-text",
                "Before you begin your enchanted journey through the advent calendar, please tell us your name so we can remember your progress."
            ),
            textInput("user_name", NULL, placeholder = "Enter your name...", 
                      width = "100%"),
            actionButton("enter_calendar", "Enter the Calendar", 
                         class = "enter-btn"),
            div(id = "loading_message", class = "loading-text", style = "display: none;",
                "Loading your progress...")
        )
    ),
    
    # Test mode banner
    conditionalPanel(
        condition = "true",
        uiOutput("test_banner")
    ),
    
    # User greeting
    hidden(
        div(id = "user_greeting_div", class = "user-greeting",
            uiOutput("user_greeting")
        )
    ),
    
    hidden(
        div(id = "main_calendar",
            div(class = "title", "✨ Enchanted Advent Calendar ✨"),
            
            div(class = "calendar-grid",
                lapply(day_order, function(i) {
                    size <- day_sizes[[as.character(i)]]
                    size_class <- paste0("size-", size[1], "-", size[2])
                    
                    div(
                        id = paste0("day_", i),
                        class = paste("day-box locked", size_class),
                        onclick = paste0("Shiny.setInputValue('day_clicked', ", i, ", {priority: 'event'})"),
                        div(class = "day-number", i)
                    )
                })
            )
        )
    ),
    
    hidden(
        div(id = "modal_overlay", class = "modal-overlay",
            onclick = "Shiny.setInputValue('close_modal', true, {priority: 'event'})")
    ),
    
    hidden(
        div(id = "quote_modal", class = "quote-modal",
            h2(id = "modal_title", style = "text-align: center; margin-top: 0;"),
            div(id = "modal_quote", class = "quote-content"),
            div(style = "text-align: center;",
                tags$button(class = "close-btn", 
                            onclick = "Shiny.setInputValue('close_modal', true, {priority: 'event'})",
                            "Close")
            )
        )
    )
)

server <- function(input, output, session) {
    
    # Reactive values
    current_user <- reactiveVal(NULL)
    opened_days <- reactiveVal(numeric(0))
    calendar_initialized <- reactiveVal(FALSE)
    
    # Test mode banner
    output$test_banner <- renderUI({
        if (TEST_MODE) {
            div(class = "test-mode-banner",
                "⚠️ TEST MODE: All days are unlocked for testing ⚠️")
        }
    })
    
    # User greeting
    output$user_greeting <- renderUI({
        req(current_user())
        days_opened <- length(opened_days())
        paste0("Welcome back, ", current_user(), "! You've opened ", days_opened, " day", 
               if(days_opened != 1) "s" else "", " so far. ✨")
    })
    
    # Handle name entry
    observeEvent(input$enter_calendar, {
        req(input$user_name)
        name <- trimws(input$user_name)
        
        if (nchar(name) > 0) {
            # Disable button and show loading
            disable("enter_calendar")
            runjs("$('#loading_message').show();")
            
            current_user(name)
            
            # Load user's progress from Google Sheets
            progress <- load_user_progress(name)
            opened_days(progress)
            
            # Hide welcome, show calendar
            hide("welcome_screen")
            show("main_calendar")
            show("user_greeting_div")
            
            # Mark as initialized
            calendar_initialized(TRUE)
        }
    })
    
    # Initialize the calendar display
    observe({
        req(calendar_initialized())
        
        current_date <- Sys.Date()
        december_first <- as.Date(paste0(format(current_date, "%Y"), "-12-01"))
        
        # Calculate which days should be unlocked
        if (TEST_MODE) {
            unlocked_days <- 1:24
        } else if (current_date >= december_first && format(current_date, "%m") == "12") {
            current_day <- as.numeric(format(current_date, "%d"))
            unlocked_days <- 1:min(current_day, 24)
        } else if (current_date > as.Date(paste0(format(current_date, "%Y"), "-12-24"))) {
            unlocked_days <- 1:24
        } else {
            unlocked_days <- numeric(0)
        }
        
        # Update UI for each day
        for (i in 1:24) {
            if (i %in% opened_days()) {
                runjs(paste0("$('#day_", i, "').removeClass('locked unlocked').addClass('opened');"))
            } else if (i %in% unlocked_days) {
                runjs(paste0("$('#day_", i, "').removeClass('locked').addClass('unlocked');"))
            }
        }
    })
    
    # Handle day clicks
    observeEvent(input$day_clicked, {
        req(current_user())
        day <- input$day_clicked
        current_date <- Sys.Date()
        december_first <- as.Date(paste0(format(current_date, "%Y"), "-12-01"))
        
        # Check if day is unlocked
        if (TEST_MODE) {
            is_unlocked <- TRUE
        } else if (current_date >= december_first && format(current_date, "%m") == "12") {
            current_day <- as.numeric(format(current_date, "%d"))
            is_unlocked <- day <= min(current_day, 24)
        } else if (current_date > as.Date(paste0(format(current_date, "%Y"), "-12-24"))) {
            is_unlocked <- TRUE
        } else {
            is_unlocked <- FALSE
        }
        
        if (is_unlocked) {
            # Mark as opened if not already
            opened <- opened_days()
            if (!(day %in% opened)) {
                opened_days(c(opened, day))
                runjs(paste0("$('#day_", day, "').removeClass('unlocked').addClass('opened');"))
                
                # Save to Google Sheets
                save_day_opened(current_user(), day)
            }
            
            # Get background image for this day
            bg_image <- background_images[[as.character(day)]]
            
            # Get background image for this day
            bg_image <- background_images[[as.character(day)]]
            
            # Prepare quote text (replace newlines with <br> for HTML)
            quote_text <- gsub("\n", "<br>", quotes[[day]])
            # Escape single quotes for JavaScript
            quote_text <- gsub("'", "\\\\'", quote_text)
            
            # Show quote with background image
            runjs(paste0("$('#quote_modal').css('background-image', 'url(", bg_image, ")');"))
            runjs(paste0("$('#modal_title').text('Day ", day, "');"))
            runjs(paste0("$('#modal_quote').html('", quote_text, "');"))
            show("modal_overlay")
            show("quote_modal")
        }
    })
    
    # Close modal
    observeEvent(input$close_modal, {
        hide("quote_modal")
        hide("modal_overlay")
    })
}

shinyApp(ui = ui, server = server)