package Models;

import java.math.BigDecimal;

public class Room {

    private int        roomId;
    private String     roomNumber;
    private String     status;
    private String     image;
    private boolean    isDeleted;

    // FK + denormalised fields from LEFT JOIN room_category
    private int        categoryId;
    private String     categoryName;
    private BigDecimal basePrice;
    private BigDecimal pricePerDay;

    // Physical attributes
    private BigDecimal areaMSquare;   // area_m2 column
    private int        maxOccupants;  // max_occupants column

    public Room() {}

    // Original constructor (backward compatible)
    public Room(int roomId, String roomNumber, String status, String image, boolean isDeleted) {
        this.roomId     = roomId;
        this.roomNumber = roomNumber;
        this.status     = status;
        this.image      = image;
        this.isDeleted  = isDeleted;
    }

    // Full constructor
    public Room(int roomId, String roomNumber, String status, String image,
                boolean isDeleted, int categoryId, String categoryName, BigDecimal basePrice) {
        this(roomId, roomNumber, status, image, isDeleted);
        this.categoryId   = categoryId;
        this.categoryName = categoryName;
        this.basePrice    = basePrice;
    }

    public int        getRoomId()       { return roomId; }
    public String     getRoomNumber()   { return roomNumber; }
    public String     getStatus()       { return status; }
    public String     getImage()        { return image; }
    public boolean    isIsDeleted()     { return isDeleted; }
    public int        getCategoryId()   { return categoryId; }
    public String     getCategoryName() { return categoryName; }
    public BigDecimal getBasePrice()    { return basePrice; }
    public BigDecimal getPricePerDay()  { return pricePerDay; }
    public BigDecimal getAreaMSquare()  { return areaMSquare; }
    public int        getMaxOccupants() { return maxOccupants; }

    public void setRoomId(int roomId)             { this.roomId = roomId; }
    public void setRoomNumber(String roomNumber)  { this.roomNumber = roomNumber; }
    public void setStatus(String status)          { this.status = status; }
    public void setImage(String image)            { this.image = image; }
    public void setIsDeleted(boolean isDeleted)   { this.isDeleted = isDeleted; }
    public void setCategoryId(int categoryId)     { this.categoryId = categoryId; }
    public void setCategoryName(String n)         { this.categoryName = n; }
    public void setBasePrice(BigDecimal p)        { this.basePrice = p; }
    public void setPricePerDay(BigDecimal p)    { this.pricePerDay = p; }
    public void setAreaMSquare(BigDecimal a)      { this.areaMSquare = a; }
    public void setMaxOccupants(int m)            { this.maxOccupants = m; }
}
