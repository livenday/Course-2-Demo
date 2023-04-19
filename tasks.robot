*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library    RPA.Browser.Selenium    auto_close=${False}
Library    RPA.HTTP
Library    RPA.Tables
Library    RPA.PDF
Library    RPA.Archive
Library    RPA.Assistant

*** Tasks ***
Orders robots attend from RobotSpareBin Industries Inc
    [Documentation]
    ...    En este ejemplo recibimos entradas del usuario
    ...    Se puede recibir la url de la página para crear ordenes.
    ...    https://robotsparebinindustries.com/#/robot-order
    # Clear Dialog
    Add Heading    Input from User
    Add text input    text_input    please enter URL
    Add submit buttons    buttons=Submit,Cancel    default=Submit
    ${result}=    Run dialog
    ${url}=    Set Variable    ${result}[text_input]
    Log To Console    ${url}
    Open the robot order website with param    ${url}
    ${orders}=    Get orders
    FOR    ${order}    IN    @{orders}
        Close the annoying modal
        Wait Until Keyword Succeeds    5x    15 sec    Fill the form   ${order}
        Download and store the receipts orders    ${order}
        Order another robot
    END
    Archive output PDFs
    [Teardown]    Close RobotSpareBin Browser

*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Open the robot order website with param
    [Arguments]    ${url}
    Open Available Browser    ${url}

Download file orders
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=${True}

Get orders
    Download file orders
    ${orders}=
    ...    Read table from CSV    ${CURDIR}${/}orders.csv
    ...    header=${True}
    RETURN    ${orders}

Fill the form
    [Arguments]    ${_order}
    Select From List By Value    head    ${_order}[Head]
    Select Radio Button    body    ${_order}[Body]
    Input Text    address    ${_order}[Address]    ${True}
    Input Text    xpath:/html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${_order}[Legs]    ${True}    
    Click Button    preview
    Click Button    order
    Wait Until Page Contains Element    order-another

Close the annoying modal
    Click Button    xpath://*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]

Download and store the receipts orders
    [Arguments]    ${order}
    Store the receipt as a PDF file   ${order}[Order number]
    Take a screenshot of the robot    ${order}[Order number] 
    Embed the robot screenshot to the receipt PDF file    ${order}[Order number]
    
Store the receipt as a PDF file
    [Arguments]    ${order_number}
    Wait Until Element Is Visible    id:order-completion
    ${receipt_html}    Get Element Attribute    id:order-completion    outerHTML
    Html To Pdf    ${receipt_html}    ${OUTPUT DIR}${/}receipts${/}${order_number}.pdf

Take a screenshot of the robot
    [Arguments]    ${order_number}
    Wait Until Element Is Visible    id:robot-preview-image
    Screenshot    id:robot-preview-image    ${OUTPUT DIR}${/}receipts${/}${order_number}.png

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${order_number}
    Open Pdf    ${OUTPUT DIR}${/}receipts${/}${order_number}.pdf
    #${files}=    Create List    ${OUTPUT DIR}${/}receipts${/}${order_number}.PNG:align=center,format=A4
    #Add Files To PDF    ${files}    ${OUTPUT DIR}${/}receipts${/}${order_number}.pdf
    Add Watermark Image To PDF
    ...             image_path=${OUTPUT DIR}${/}receipts${/}${order_number}.png
    ...             source_path=${OUTPUT DIR}${/}receipts${/}${order_number}.pdf
    ...             output_path=${OUTPUT DIR}${/}receipts${/}${order_number}.pdf
    Close Pdf     ${OUTPUT DIR}${/}receipts${/}${order_number}.pdf


Order another robot
    TRY
        Wait Until Page Contains Element    order-another
        Click Button    order-another
    FINALLY
        Log    No se encontro Boton para cerrar dialogo.
    END

Archive output PDFs
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}/PDFs.zip
    Archive Folder With Zip    ${OUTPUT DIR}${/}receipts    ${zip_file_name}

Close RobotSpareBin Browser
    Close Browser

Orders robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=    Get orders
    FOR    ${order}    IN    @{orders}
        Close the annoying modal
        Wait Until Keyword Succeeds    5x    15 sec    Fill the form   ${order}
        Download and store the receipts orders    ${order}
        Order another robot
    END
    Archive output PDFs
    [Teardown]    Close RobotSpareBin Browser

