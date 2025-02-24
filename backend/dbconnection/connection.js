const mongoose =require("mongoose")

mongoose.connect("mongodb+srv://rathodindrajit:rathodindrajit@cluster0.yfadb.mongodb.net/digitalmoney?retryWrites=true&w=majority&appName=Cluster0").then(()=>{
    console.log("connection succesfull")
}).catch((e)=>{
    console.log(e)
})
