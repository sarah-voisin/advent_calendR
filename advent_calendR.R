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
        grid-template-columns: repeat(6, 1fr);
        gap: 15px;
        max-width: 900px;
        margin: 0 auto;
        padding: 20px;
      }
      .day-box {
        aspect-ratio: 1;
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
        font-size: 2em;
        z-index: 1;
      }
    "))
    ),
    
    div(class = "title", "✨ Enchanted Advent Calendar ✨"),
    
    div(class = "calendar-grid",
        lapply(1:24, function(i) {
            div(
                id = paste0("day_", i),
                class = "day-box locked",
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
    
    # Reactive value to store opened days
    opened_days <- reactiveVal(numeric(0))
    
    # Initialize the calendar on startup
    observe({
        current_date <- Sys.Date()
        december_first <- as.Date(paste0(format(current_date, "%Y"), "-12-01"))
        
        # Calculate which days should be unlocked
        if (current_date >= december_first && format(current_date, "%m") == "12") {
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
        if (current_date >= december_first && format(current_date, "%m") == "12") {
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