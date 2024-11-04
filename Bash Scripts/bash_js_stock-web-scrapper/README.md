# Stock Price Scraper Script

This Node.js script scrapes stock prices from the Screener.in website using the `request` and `cheerio` libraries. It extracts stock prices for various companies and writes them into specific cells of an Excel file using a custom `writeToCell` function.

## Table of Contents

- [Prerequisites](#prerequisites)
- [How It Works](#how-it-works)
- [Setup](#setup)
- [Usage](#usage)
- [Customization](#customization)
- [Notes](#notes)

## Prerequisites

Before running the script, ensure the following dependencies are installed:

1. **Node.js**: Install from [Node.js official website](https://nodejs.org).
2. **NPM Modules**: This script uses the following modules:
   - `request`: for making HTTP requests to get the HTML content of the webpage.
   - `cheerio`: for parsing and extracting data from the HTML.
   - `xlsx` (assumed in the `excelfunction` file): for writing data to Excel files.

   You can install these dependencies using the following command:
   ```bash
   npm install request cheerio
   ```

3. The `writeToCell` function is assumed to exist in a file called `excelfunction.js`. This function writes data to a specified cell in an Excel sheet. Ensure that file is available in the same directory as the script.

## How It Works

1. **Scraping Stock Prices**: The script sends a request to Screener.in for each specified company's stock page.
2. **Parsing HTML**: It uses Cheerio to load the HTML body and locate the stock price using a CSS selector.
3. **Extracting the Price**: The price is extracted, cleaned (currency symbols and commas are removed), and converted into a numeric value.
4. **Writing to Excel**: The stock price is written into the appropriate cell in the Excel file using the `writeToCell` function.

## Setup

1. **URLs for Stocks**: The URLs of the companies for which stock prices are being scraped are predefined:
   ```js
   let dmart = "https://www.screener.in/company/DMART"
   let kotakbank = "https://www.screener.in/company/KOTAKBANK"
   let aavas = "https://www.screener.in/company/AAVAS"
   let cams = "https://www.screener.in/company/CAMS"
   let hdfcbank = "https://www.screener.in/company/HDFCBANK"
   let deltacorp = "https://www.screener.in/company/DELTACORP"
   let sbicards = "https://www.screener.in/company/SBICARD"
   let hul = "https://www.screener.in/company/HINDUNILVR"
   ```

2. **Excel Sheet**: The stock prices will be written to an Excel file (`file.xlsx`) in specific cells in `Sheet1`. The cell mapping is as follows:
   - DMART: `B3`
   - Kotak Bank: `B4`
   - AAVAS: `B5`
   - CAMS: `B6`
   - HDFC Bank: `B7`
   - Delta Corp: `B8`
   - SBI Cards: `B10`
   - HUL: `B11`

## Usage

1. **Clone or download the script** and place it in a directory.
2. **Ensure you have the `excelfunction.js` file** with the `writeToCell` function.
3. Run the script using Node.js:
   ```bash
   node script_name.js
   ```

   Replace `script_name.js` with the actual name of your script file.

## Customization

You can customize the script as needed:

- **Add More Stocks**: To scrape more stock prices, simply add new URLs and cells in the `stockprice` function calls, like so:
  ```js
  let newCompany = "https://www.screener.in/company/NEWCOMPANY"
  stockprice(newCompany, "B12");
  ```

- **Change Excel File or Sheet**: Modify the `writeToCell` function calls if you want to change the target Excel file or sheet.

## Notes

- The script assumes that the stock price is located at the CSS selector: 
  ```js
  '#top > div.flex.flex-space-between.flex-gap-8 > div > div.font-size-18.strong.line-height-14 > div.flex.flex-align-center > span:nth-child(1)'
  ```
  If the structure of the Screener.in website changes, you will need to update this selector.

- **Error Handling**: The script logs errors if any request fails, but you can add more sophisticated error handling and logging as needed.

---

This script provides a basic setup for scraping stock prices and writing them to an Excel file. Modify it according to your specific requirements!