const request = require("request");
const cheerio = require("cheerio");

const { writeToCell } = require("./excelfunction")



function stockprice(url, cell) {
    request(url, (error, response, body) => {
        if (!error && response.statusCode === 200) {

            const $ = cheerio.load(body);
            const element = $('#top > div.flex.flex-space-between.flex-gap-8 > div > div.font-size-18.strong.line-height-14 > div.flex.flex-align-center > span:nth-child(1)');
            const data = element.text();


            // Remove the currency symboland comma
            const plainNumber = data.replace(/₹|,/g, '');

            // Convert to a numeric value
            const numericValue = parseInt(plainNumber, 10);
            // console.log(numericValue);


            writeToCell('file.xlsx', 'Sheet1', cell, numericValue);
           
        }
    });
}





let dmart = "https://www.screener.in/company/DMART"
let kotakbank = "https://www.screener.in/company/KOTAKBANK"
let aavas = "https://www.screener.in/company/AAVAS"
let cams = "https://www.screener.in/company/CAMS"
let hdfcbank = "https://www.screener.in/company/HDFCBANK"
let deltacorp = "https://www.screener.in/company/DELTACORP"

let sbicards = "https://www.screener.in/company/SBICARD"
let hul = "https://www.screener.in/company/HINDUNILVR"

stockprice(dmart, "B3");
stockprice(kotakbank, "B4");
stockprice(aavas, "B5");
stockprice(cams, "B6");
stockprice(hdfcbank, "B7");
stockprice(deltacorp, "B8");
// stockprice(niftyit, "B9");
stockprice(sbicards, "B10");
stockprice(hul, "B11");







