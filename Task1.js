const prompt = require("prompt-sync")();
function ArrayIntersection(arr1 ,arr2)
{
    const arr =[];
    // Loop for array1
    for(let i = 0 ; i<arr1.length;i++)
    {
        // Loop for array2
        for(let j = 0 ; j<arr2.length;j++)
        {
            if(arr1[i] == arr2[j])
            {
                arr.push(arr1[i]);
            }
        }
    }
    console.log(arr);
}
const arr1 = []; // dynamic array
const arr2 = []; // dynamic array
let Arr1Length = parseInt(prompt("Enter Length of array1: "));
let Arr2Length = parseInt(prompt("Enter Length of array2: "));
// Taking array elements of arr1
for(let i = 0; i<Arr1Length;i++)
{
    let element = parseInt(prompt("Enter elements of an array1: "));
    arr1.push(element);
}
// Taking array element of arr2
for(let i = 0; i<Arr2Length;i++)
{
    let element = parseInt(prompt("Enter elements of an array2: "));
    arr2.push(element);
}
// Calling function with parameters
ArrayIntersection(arr1,arr2);