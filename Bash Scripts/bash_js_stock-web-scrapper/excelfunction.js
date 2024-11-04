const ExcelJS = require('exceljs');

// Create a lock to ensure synchronous write operations
const writeLock = {};


async function writeToCell(filename, sheetname, cell, data) {

  // Acquire the write lock
  while (writeLock[filename]) {
    await new Promise(resolve => setTimeout(resolve, 100));
  }
  writeLock[filename] = true;


  try {
    const workbook = new ExcelJS.Workbook();
    await workbook.xlsx.readFile(filename);

    const worksheet = workbook.getWorksheet(sheetname);
    const selectedCell = worksheet.getCell(cell);

    selectedCell.value = data;

    await workbook.xlsx.writeFile(filename);
    console.log(`Data "${data}" written to cell ${cell} in ${filename}.`);
  } catch (error) {
    console.error(`Error writing to cell ${cell} in ${filename}: ${error}`);
  } finally {
    // Release the write lock
    writeLock[filename] = false;
  }
}



module.exports = {
  writeToCell
}