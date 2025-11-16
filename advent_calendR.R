library(shiny)
library(shinyjs)

# Fantasy-themed poems for each day
poems <- list(
    "In winter's realm where frost ferns grow,\nA single star begins to glow.",
    "Through enchanted woods the north wind calls,\nAs silver snow on pine trees falls.",
    "A dragon sleeps beneath the hill,\nWhile magic wraps the world so still.",
    "The elven choir sings at dawn,\nOf legends old and heroes born.",
    "Within the cave of crystal ice,\nLies treasure beyond mortal price.",
    "The wizard's staff lights up the night,\nGuiding travelers toward the light.",
    "In fairy rings beneath the moon,\nThe sprites will dance and play their tune.",
    "The ancient oak speaks wisdom deep,\nTo those who listen while they sleep.",
    "A phoenix rises from the snow,\nWith feathers of a crimson glow.",
    "The unicorn drinks from the stream,\nWhere starlight dances like a dream.",
    "In castle towers far above,\nA kingdom celebrates with love.",
    "The mermaid's song from frozen seas,\nDrifts gently on the winter breeze.",
    "Through portals made of northern lights,\nAdventurers seek wondrous sights.",
    "The gnome's small home beneath the root,\nIs filled with treasures and gold loot.",
    "A spell is cast on winter's eve,\nFor those who truly still believe.",
    "The griffin guards the mountain pass,\nWhere golden sunlight meets the grass.",
    "In libraries of ancient lore,\nLie secrets never told before.",
    "The fairy queen in robes of white,\nBrings blessings on this sacred night.",
    "A prophecy from days of old,\nOf heroes brave and hearts of gold.",
    "The crystal ball reveals the way,\nTo find the magic Christmas day.",
    "Through enchanted forests thick with snow,\nThe mystical creatures come and go.",
    "A wishing well beneath the tree,\nGrants dreams to those who dare to see.",
    "The final quest is drawing near,\nAs magic fills the atmosphere.",
    "On Christmas Eve the spells unite,\nAnd fill the world with pure delight."
)

# *** TEST MODE PARAMETER - SET TO TRUE TO UNLOCK ALL DAYS ***
TEST_MODE <- TRUE  # Change to TRUE to test opening all days

# Shuffled day order for visual interest
day_order <- c(15, 3, 22, 8, 19, 1, 12, 24, 6, 17, 4, 21, 
               9, 14, 2, 20, 7, 23, 11, 16, 5, 18, 10, 13)

# Define sizes for collage effect (1 = normal, 2 = double width, 3 = double height)
# Format: c(width_span, height_span)
day_sizes <- list(
    '1' = c(1, 1), '2' = c(1, 1), '3' = c(2, 1), '4' = c(1, 1),
    '5' = c(1, 2), '6' = c(1, 1), '7' = c(1, 1), '8' = c(2, 2),
    '9' = c(1, 1), '10' = c(1, 1), '11' = c(1, 1), '12' = c(1, 2),
    '13' = c(2, 1), '14' = c(1, 1), '15' = c(1, 1), '16' = c(1, 1),
    '17' = c(2, 1), '18' = c(1, 1), '19' = c(1, 1), '20' = c(1, 1),
    '21' = c(1, 2), '22' = c(1, 1), '23' = c(1, 1), '24' = c(2, 2)
)

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
      .poem-modal {
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        background: linear-gradient(135deg, #4a3573 0%, #2d1b4e 100%);
        border: 3px solid #ffd700;
        border-radius: 20px;
        padding: 40px;
        max-width: 500px;
        width: 90%;
        box-shadow: 0 10px 50px rgba(0,0,0,0.5);
        z-index: 1000;
        color: #ffd700;
      }
      .poem-content {
        font-size: 1.2em;
        line-height: 1.8;
        text-align: center;
        white-space: pre-line;
        margin: 20px 0;
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
    "))
    ),
    
    # Test mode banner
    conditionalPanel(
        condition = "true",
        uiOutput("test_banner")
    ),
    
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
    ),
    
    hidden(
        div(id = "modal_overlay", class = "modal-overlay",
            onclick = "Shiny.setInputValue('close_modal', true, {priority: 'event'})")
    ),
    
    hidden(
        div(id = "poem_modal", class = "poem-modal",
            h2(id = "modal_title", style = "text-align: center; margin-top: 0;"),
            div(id = "modal_poem", class = "poem-content"),
            div(style = "text-align: center;",
                tags$button(class = "close-btn", 
                            onclick = "Shiny.setInputValue('close_modal', true, {priority: 'event'})",
                            "Close")
            )
        )
    )
)

server <- function(input, output, session) {
    
    # Test mode banner
    output$test_banner <- renderUI({
        if (TEST_MODE) {
            div(class = "test-mode-banner",
                "⚠️ TEST MODE: All days are unlocked for testing ⚠️")
        }
    })
    
    # Reactive value to store opened days
    opened_days <- reactiveVal(numeric(0))
    
    # Initialize the calendar on startup
    observe({
        current_date <- Sys.Date()
        december_first <- as.Date(paste0(format(current_date, "%Y"), "-12-01"))
        
        # Calculate which days should be unlocked
        if (TEST_MODE) {
            # In test mode, unlock all days
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
            if (i %in% unlocked_days) {
                runjs(paste0("$('#day_", i, "').removeClass('locked').addClass('unlocked');"))
            }
        }
    })
    
    # Handle day clicks
    observeEvent(input$day_clicked, {
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
            # Mark as opened
            opened <- opened_days()
            if (!(day %in% opened)) {
                opened_days(c(opened, day))
                runjs(paste0("$('#day_", day, "').removeClass('unlocked').addClass('opened');"))
            }
            
            # Show poem
            runjs(paste0("$('#modal_title').text('Day ", day, "');"))
            runjs(paste0("$('#modal_poem').text('", gsub("\n", "\\\\n", poems[[day]]), "');"))
            show("modal_overlay")
            show("poem_modal")
        }
    })
    
    # Close modal
    observeEvent(input$close_modal, {
        hide("poem_modal")
        hide("modal_overlay")
    })
}

shinyApp(ui = ui, server = server)